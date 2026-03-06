package llua;

import llua.State;
import llua.Lua;
import llua.LuaL;
import llua.Macro.*;
import haxe.DynamicAccess;

class Convert {

	// -----------------------------------------------------------------------
	// Configuration
	// -----------------------------------------------------------------------

	/** If true, unsupported Haxe→Lua conversions emit a trace warning. */
	public static var enableUnsupportedTraces:Bool = false;

	// -----------------------------------------------------------------------
	// Haxe → Lua
	// -----------------------------------------------------------------------

	/**
	 * Push a Haxe value onto the Lua stack.
	 * Returns true if the value was pushed, false if unsupported.
	 */
	public static function toLua(l:State, val:Any):Bool {
		switch (Type.typeof(val)) {
			case TNull:
				Lua.pushnil(l);
			case TBool:
				Lua.pushboolean(l, val);
			case TInt:
				Lua.pushinteger(l, cast(val, Int));
			case TFloat:
				Lua.pushnumber(l, val);
			case TClass(String):
				Lua.pushstring(l, cast(val, String));
			case TClass(Array):
				arrayToLua(l, val);
			case TClass(haxe.ds.StringMap) | TClass(haxe.ds.IntMap) | TClass(haxe.ds.ObjectMap):
				mapToLua(l, val);
			case TObject:
				anonToLua(l, val);
			case TFunction:
				// Push a Haxe function as a Lua C closure via the callback system.
				// The function must be registered through Lua_helper so the
				// closure name can be resolved in the callback dispatcher.
				// For anonymous push, we register under a generated key.
				if (enableUnsupportedTraces)
					trace('TFunction push not supported via toLua; use Lua_helper.add_callback instead.');
				Lua.pushnil(l);
				return false;
			default:
				if (enableUnsupportedTraces)
					trace('Haxe value $val of type ${Type.typeof(val)} not supported for toLua.');
				Lua.pushnil(l);
				return false;
		}
		return true;
	}

	/** Push an Array as a 1-based Lua sequence table. */
	@:keep public static inline function arrayToLua(l:State, arr:Array<Any>):Void {
		Lua.createtable(l, arr.length, 0);
		for (i => v in arr) {
			// Use rawseti for integer keys — faster than pushinteger+settable.
			toLua(l, v);
			Lua.rawseti(l, -2, i + 1);
		}
	}

	/** Push a Map (string or int keys) as a Lua table. */
	@:keep public static function mapToLua(l:State, res:Dynamic):Void {
		Lua.createtable(l, 0, 0);
		// Works for StringMap, IntMap, ObjectMap — all expose iterator().
		var map:haxe.Constraints.IMap<Dynamic, Dynamic> = cast res;
		for (key => val in map) {
			toLua(l, key);
			toLua(l, val);
			Lua.settable(l, -3);
		}
	}

	/** Push an anonymous object as a Lua table. */
	@:keep public static inline function anonToLua(l:State, res:Any):Void {
		var fields = Reflect.fields(res);
		Lua.createtable(l, 0, fields.length);
		for (n in fields) {
			Lua.pushstring(l, n);
			toLua(l, Reflect.field(res, n));
			Lua.settable(l, -3);
		}
	}

	/**
	 * Set a Lua global directly to a Haxe value.
	 * Avoids the old double-push pattern.
	 */
	@:keep public static inline function setGlobal(l:State, index:String, value:Dynamic):Void {
		toLua(l, value);
		Lua.setglobal(l, index);
	}

	// -----------------------------------------------------------------------
	// Lua → Haxe
	// -----------------------------------------------------------------------

	/** Read a value at stack index `v` and convert it to a Haxe value. */
	public static function fromLua(l:State, v:Int):Any {
		return switch (Lua.type(l, v)) {
			case Lua.LUA_TNIL:
				null;
			case Lua.LUA_TBOOLEAN:
				Lua.toboolean(l, v);
			case Lua.LUA_TNUMBER:
				// Preserve Int vs Float distinction when the number is integral.
				var n = Lua.tonumber(l, v);
				var ni = Lua.tointeger(l, v);
				(n == ni) ? cast ni : n;
			case Lua.LUA_TSTRING:
				Lua.tostring(l, v);
			case Lua.LUA_TTABLE:
				toHaxeObj(l, v);
			case Lua.LUA_TFUNCTION:
				// Consume the value into a registry ref so the function stays alive.
				Lua.pushvalue(l, v);
				new LuaCallback(l, LuaL.ref(l, Lua.LUA_REGISTRYINDEX));
			default:
				if (enableUnsupportedTraces)
					trace('Lua value at $v of type ${Lua.type(l, v)} not supported for fromLua.');
				null;
		}
	}

	/**
	 * Convert a Lua table at stack index `i` to either an Array or an
	 * anonymous object, depending on whether all keys are consecutive integers.
	 */
	public static function toHaxeObj(l:State, i:Int):Any {
		var isArray = true;
		var maxIndex = 0;
		var count = 0;

		// First pass: inspect keys.
		loopTable(l, i, {
			count++;
			if (isArray) {
				if (Lua.type(l, -2) != Lua.LUA_TNUMBER) {
					isArray = false;
				} else {
					var n = Lua.tonumber(l, -2);
					var ni = Std.int(n);
					if (n != ni || ni < 1) {
						isArray = false;
					} else if (ni > maxIndex) {
						maxIndex = ni;
					}
				}
			}
		});

		if (count == 0) return {};

		// If index range matches count it is a proper sequence (no holes).
		if (isArray && maxIndex == count) {
			var arr:Array<Dynamic> = [];
			arr.resize(count);
			loopTable(l, i, {
				arr[Std.int(Lua.tonumber(l, -2)) - 1] = fromLua(l, -1);
			});
			return arr;
		}

		// Mixed or string-keyed table → anonymous object.
		var obj:DynamicAccess<Any> = {};
		loopTable(l, i, {
			var key:String = switch (Lua.type(l, -2)) {
				case t if (t == Lua.LUA_TSTRING): Lua.tostring(l, -2);
				case t if (t == Lua.LUA_TNUMBER): Std.string(Lua.tonumber(l, -2));
				default: null;
			};
			if (key != null) obj.set(key, fromLua(l, -1));
		});
		return obj;
	}

	// -----------------------------------------------------------------------
	// Convenience call helpers
	// -----------------------------------------------------------------------

	/**
	 * Call a Lua global function by name with Haxe arguments.
	 *
	 * - If `func` is null, the function already on top of the stack is called.
	 * - If `multipleReturns` is true, returns an Array of all return values;
	 *   otherwise returns the first (or only) return value.
	 * - Throws `LuaException` on error.
	 *
	 * Bug fix: the original returned `fromLua(l, fromLua(l, -1))` — a value
	 * was passed as a stack index. Now correctly reads index -1.
	 */
	public static function callLuaFunction(l:State, ?func:String, ?args:Array<Dynamic>, ?multipleReturns:Bool = false):Dynamic {
		if (func != null) Lua.getglobal(l, func);

		var argc = 0;
		if (args != null) {
			argc = args.length;
			for (arg in args) toLua(l, arg);
		}

		if (multipleReturns) {
			LuaException.ifErrorThrow(l, Lua.pcall(l, argc, Lua.LUA_MULTRET, 0));
			var nresults = Lua.gettop(l);
			var ret:Array<Dynamic> = [];
			for (i in 0...nresults)
				ret.push(fromLua(l, i + 1));
			Lua.settop(l, 0); // clear stack
			return ret;
		} else {
			LuaException.ifErrorThrow(l, Lua.pcall(l, argc, 1, 0));
			// Bug fix: was `fromLua(l, fromLua(l,-1))` — fromLua returns Any, not Int.
			var result = fromLua(l, -1);
			Lua.pop(l, 1);
			return result;
		}
	}

	/**
	 * Call a Lua global function, ignoring any return values.
	 * Slightly faster than `callLuaFunction` when returns are not needed.
	 * Throws `LuaException` on error.
	 */
	public static function callLuaFuncNoReturns(l:State, func:String, ?args:Array<Dynamic>):Void {
		Lua.getglobal(l, func);
		var argc = 0;
		if (args != null) {
			argc = args.length;
			for (arg in args) toLua(l, arg);
		}
		LuaException.ifErrorThrow(l, Lua.pcall(l, argc, 0, 0));
	}

	/**
	 * Haxe callback helper: call a Haxe function from inside a Lua C callback.
	 * Returns the number of values pushed onto the Lua stack (0 or 1).
	 */
	public static function callback_handler(cbf:Dynamic, l:State, ?object:Dynamic):Int {
		var nparams = Lua.gettop(l);
		var args:Array<Dynamic> = [for (i in 0...nparams) fromLua(l, i + 1)];
		try {
			var ret:Dynamic = Reflect.callMethod(object, cbf, args);
			if (ret != null) {
				toLua(l, ret);
				return 1;
			}
		} catch (e:Dynamic) {
			var msg = (e.message != null) ? e.message : Std.string(e);
			trace('llua callback error: $msg');
			throw e;
		}
		return 0;
	}

}

// hxcpp anonymous object factory
@:include('hxcpp.h')
@:native('hx::Anon')
extern class Anon {
	@:native('hx::Anon_obj::Create')
	public static function create():Anon;
	@:native('hx::Anon_obj::Add')
	public function add(k:String, v:Any):Void;
}
