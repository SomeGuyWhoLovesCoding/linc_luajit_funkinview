package llua;

#if cpp
import llua.State;
import llua.Convert;


@:keep
@:include('linc_lua.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('lua'))
#end
extern class Lua {

	@:native('lua_upvalueindex')
	static function upvalueindex(i:Int):Int;

	/* option for multiple returns in `lua_pcall' and `lua_call' */
	public static inline var LUA_MULTRET:Int = (-1);

	/* pseudo-indices */
	public static inline var LUA_REGISTRYINDEX:Int = (-10000);
	public static inline var LUA_ENVIRONINDEX:Int  = (-10001);
	public static inline var LUA_GLOBALSINDEX:Int  = (-10002);

	/* thread status */
	public static inline var LUA_OK:Int       = 0;
	public static inline var LUA_YIELD:Int    = 1;
	public static inline var LUA_ERRRUN:Int   = 2;
	public static inline var LUA_ERRSYNTAX:Int = 3;
	public static inline var LUA_ERRMEM:Int   = 4;
	public static inline var LUA_ERRERR:Int   = 5;

	/* basic types */
	public static inline var LUA_TNONE:Int          = (-1);
	public static inline var LUA_TNIL:Int            = 0;
	public static inline var LUA_TBOOLEAN:Int        = 1;
	public static inline var LUA_TLIGHTUSERDATA:Int  = 2;
	public static inline var LUA_TNUMBER:Int         = 3;
	public static inline var LUA_TSTRING:Int         = 4;
	public static inline var LUA_TTABLE:Int          = 5;
	public static inline var LUA_TFUNCTION:Int       = 6;
	public static inline var LUA_TUSERDATA:Int       = 7;
	public static inline var LUA_TTHREAD:Int         = 8;

	/* minimum Lua stack available to a C function */
	public static inline var LUA_MINSTACK:Int = 20;

	/* state manipulation */
	@:native('lua_close')
	static function close(l:State):Void;

	@:native('lua_newthread')
	static function newthread(l:State):State;

	/* basic stack manipulation */
	@:native('lua_gettop')
	static function gettop(l:State):Int;

	@:native('lua_settop')
	static function settop(l:State, idx:Int):Void;

	@:native('lua_pushvalue')
	static function pushvalue(l:State, idx:Int):Void;

	@:native('lua_remove')
	static function remove(l:State, idx:Int):Void;

	@:native('lua_insert')
	static function insert(l:State, idx:Int):Void;

	@:native('lua_replace')
	static function replace(l:State, idx:Int):Void;

	@:native('lua_checkstack')
	static function checkstack(l:State, sz:Int):Int;

	@:native('lua_xmove')
	static function xmove(from:State, to:State, n:Int):Void;

	/* access functions (stack -> C) */
	@:noCompletion @:native('lua_isnumber')
	static function _isnumber(l:State, idx:Int):Int;
	static inline function isnumber(l:State, idx:Int):Bool return _isnumber(l, idx) != 0;

	@:noCompletion @:native('lua_isfunction')
	static function _isfunction(l:State, idx:Int):Int;
	static inline function isfunction(l:State, idx:Int):Bool return _isfunction(l, idx) != 0;

	@:noCompletion @:native('lua_isstring')
	static function _isstring(l:State, idx:Int):Int;
	static inline function isstring(l:State, idx:Int):Bool return _isstring(l, idx) != 0;

	@:noCompletion @:native('lua_iscfunction')
	static function _iscfunction(l:State, idx:Int):Int;
	static inline function iscfunction(l:State, idx:Int):Bool return _iscfunction(l, idx) != 0;

	@:noCompletion @:native('lua_isuserdata')
	static function _isuserdata(l:State, idx:Int):Int;
	static inline function isuserdata(l:State, idx:Int):Bool return _isuserdata(l, idx) != 0;

	@:noCompletion @:native('lua_isboolean')
	static function _isboolean(l:State, idx:Int):Int;
	static inline function isboolean(l:State, idx:Int):Bool return _isboolean(l, idx) != 0;

	@:native('lua_type')
	static function type(l:State, idx:Int):Int;

	@:native('linc::lua::_typename')
	static function typename(l:State, tp:Int):String;

	@:native('lua_equal')
	static function equal(l:State, idx1:Int, idx2:Int):Int;

	@:native('lua_rawequal')
	static function rawequal(l:State, idx1:Int, idx2:Int):Int;

	@:native('lua_lessthan')
	static function lessthan(l:State, idx1:Int, idx2:Int):Int;

	@:native('lua_tonumber')
	static function tonumber(l:State, idx:Int):Float;

	@:native('lua_tointeger')
	static function tointeger(l:State, idx:Int):Int;

	@:noCompletion @:native('lua_toboolean')
	static function _toboolean(l:State, idx:Int):Int;
	static inline function toboolean(l:State, idx:Int):Bool return _toboolean(l, idx) != 0;

	@:native('linc::lua::tolstring')
	static function tolstring(l:State, idx:Int, len:UInt):String;

	@:native('lua_objlen')
	static function objlen(l:State, idx:Int):Int;

	@:native('linc::lua::tocfunction')
	static function tocfunction(l:State, idx:Int):cpp.Callable<StatePointer->Int>;

	@:native('lua_touserdata')
	static function touserdata(l:State, idx:Int):Void;

	@:native('lua_tothread')
	static function tothread(l:State, idx:Int):State;

	@:native('lua_topointer')
	static function topointer(l:State, idx:Int):Void;

	/* push functions (C -> stack) */
	@:native('lua_pushnil')
	static function pushnil(l:State):Void;

	@:native('lua_pushnumber')
	static function pushnumber(l:State, n:Float):Void;

	@:native('lua_pushinteger')
	static function pushinteger(l:State, n:Int):Void;

	@:native('lua_pushlstring')
	static function pushlstring(l:State, s:String, len:Int):Void;

	@:native('lua_pushstring')
	static function pushstring(l:State, s:String):Void;

	@:native('linc::lua::pushcclosure')
	static function pushcclosure(l:State, fn:cpp.Callable<StatePointer>, n:Int):Void;

	@:noCompletion @:native('lua_pushboolean')
	static function _pushboolean(l:State, b:Int):Void;
	static inline function pushboolean(l:State, b:Bool):Void _pushboolean(l, b ? 1 : 0);

	@:native('lua_pushthread')
	static function pushthread(l:State):Int;

	/* get functions (Lua -> stack) */
	@:native('lua_gettable')
	static function gettable(l:State, idx:Int):Void;

	@:native('lua_getfield')
	static function getfield(l:State, idx:Int, k:String):Void;

	@:native('lua_rawget')
	static function rawget(l:State, idx:Int):Void;

	@:native('lua_rawgeti')
	static function rawgeti(l:State, idx:Int, n:Int):Void;

	@:native('lua_createtable')
	static function createtable(l:State, narr:Int, nrec:Int):Void;

	@:native('lua_newuserdata')
	static function newuserdata(l:State, size:Int):Void;

	@:native('lua_getmetatable')
	static function getmetatable(l:State, objindex:Int):Int;

	@:native('lua_getfenv')
	static function getfenv(l:State, idx:Int):Void;

	/* set functions (stack -> Lua) */
	@:native('lua_settable')
	static function settable(l:State, idx:Int):Void;

	@:native('lua_setfield')
	static function setfield(l:State, idx:Int, s:String):Void;

	@:native('lua_rawset')
	static function rawset(l:State, idx:Int):Void;

	@:native('lua_rawseti')
	static function rawseti(l:State, idx:Int, n:Int):Void;

	@:native('lua_setmetatable')
	static function setmetatable(l:State, objindex:Int):Int;

	@:native('lua_setfenv')
	static function lua_setfenv(l:State, idx:Int):Int;

	/* load and call functions */
	@:native('lua_call')
	static function call(l:State, nargs:Int, nresults:Int):Void;

	@:native('lua_pcall')
	static function pcall(l:State, nargs:Int, nresults:Int, errfunc:Int):Int;

	/* coroutine functions */
	@:native('lua_yield')
	static function yield(l:State, n:Int):Int;

	@:native('lua_resume')
	static function resume(l:State, narg:Int):Int;

	@:native('lua_status')
	static function status(l:State):Int;

	/* garbage collection */
	public static inline var LUA_GCSTOP:Int       = 0;
	public static inline var LUA_GCRESTART:Int    = 1;
	public static inline var LUA_GCCOLLECT:Int    = 2;
	public static inline var LUA_GCCOUNT:Int      = 3;
	public static inline var LUA_GCCOUNTB:Int     = 4;
	public static inline var LUA_GCSTEP:Int       = 5;
	public static inline var LUA_GCSETPAUSE:Int   = 6;
	public static inline var LUA_GCSETSTEPMUL:Int = 7;

	@:native('lua_gc')
	static function gc(l:State, what:Int, data:Int):Int;

	/* miscellaneous */
	@:native('lua_error')
	static function error(l:State):Int;

	@:native('lua_next')
	static function next(l:State, idx:Int):Int;

	@:native('lua_concat')
	static function concat(l:State, n:Int):Void;

	/* macros */
	@:native('lua_pop')
	static function pop(l:State, n:Int):Void;

	@:native('lua_newtable')
	static function newtable(l:State):Void;

	/**
	 * Register a Haxe function as a named Lua global.
	 * Routes through Lua_helper's callback system.
	 */
	static inline function register(l:State, name:String, f:Dynamic):Void {
		if (Type.typeof(f) == TFunction && !Lua_helper.callbacks.exists(name))
			Lua_helper.add_callback(l, name, f);
	}

	@:native('linc::lua::pushcfunction')
	static function pushcfunction(l:State, f:cpp.Callable<StatePointer->Int>):Void;

	@:native('lua_strlen')
	static function strlen(l:State, idx:Int):Int;

	@:native('lua_istable')
	static function istable(l:State, idx:Int):Int;

	@:native('lua_islightuserdata')
	static function islightuserdata(l:State, idx:Int):Int;

	@:native('lua_isnil')
	static function isnil(l:State, idx:Int):Int;

	@:native('lua_isthread')
	static function isthread(l:State, idx:Int):Int;

	@:native('lua_isnone')
	static function isnone(l:State, idx:Int):Int;

	@:native('lua_isnoneornil')
	static function isnoneornil(l:State, idx:Int):Int;

	@:native('lua_pushliteral')
	static function pushliteral(l:State, s:String):Void;

	@:native('lua_setglobal')
	static function setglobal(l:State, name:String):Void;

	@:native('lua_getglobal')
	static function getglobal(l:State, name:String):Void;

	@:native('linc::lua::tostring')
	static function tostring(l:State, idx:Int):String;

	/* hack */
	@:native('lua_setlevel')
	static function setlevel(from:State, to:State):Void;

	/* debug API event codes */
	public static inline var LUA_HOOKCALL:Int    = 0;
	public static inline var LUA_HOOKRET:Int     = 1;
	public static inline var LUA_HOOKLINE:Int    = 2;
	public static inline var LUA_HOOKCOUNT:Int   = 3;
	public static inline var LUA_HOOKTAILRET:Int = 4;

	/* debug API event masks */
	public static inline var LUA_MASKCALL:Int  = (1 << LUA_HOOKCALL);
	public static inline var LUA_MASKRET:Int   = (1 << LUA_HOOKRET);
	public static inline var LUA_MASKLINE:Int  = (1 << LUA_HOOKLINE);
	public static inline var LUA_MASKCOUNT:Int = (1 << LUA_HOOKCOUNT);

	@:native('linc::lua::getstack')
	static function getstack(l:State, level:Int, ar:Lua_Debug):Int;

	@:native('linc::lua::getinfo')
	static function getinfo(l:State, what:String, ar:Lua_Debug):Int;

	@:native('lua_getupvalue')
	static function getupvalue(l:State, funcindex:Int, n:Int):String;

	@:native('lua_setupvalue')
	static function setupvalue(l:State, funcindex:Int, n:Int):String;

	@:native('lua_gethookmask')
	static function gethookmask(l:State):Int;

	@:native('lua_gethookcount')
	static function gethookcount(l:State):Int;

	@:native('lua_upvalueid')
	static function upvalueid(l:State, idx:Int, n:Int):Void;

	@:native('lua_upvaluejoin')
	static function upvaluejoin(l:State, idx1:Int, n1:Int, idx2:Int, n2:Int):Void;

	/* ref system compatibility */
	@:native('lua_ref')
	static function ref(l:State, lock:Bool):Int;

	@:native('lua_unref')
	static function unref(l:State, ref:Int):Void;

	@:native('lua_getref')
	static function getref(l:State, ref:Int):Void;

	/* unofficial helpers */
	@:native('linc::lua::version')
	static function version():String;

	@:native('linc::lua::versionJIT')
	static function versionJIT():String;

	static inline function init_callbacks(l:State):Void {
		Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(Lua_helper.callback_handler));
	}

	@:native('linc::callbacks::set_callbacks_function')
	static function set_callbacks_function(f:cpp.Callable<State->String->Int>):Void;

	@:native('linc::callbacks::add_callback_function')
	static function add_callback_function(l:State, name:String):Void;

	@:native('linc::callbacks::remove_callback_function')
	static function remove_callback_function(l:State, name:String):Void;

	@:native('linc::helpers::register_hxtrace_lib')
	static function register_hxtrace_lib(l:State):Void;

	@:native('linc::helpers::register_hxtrace_func')
	static function register_hxtrace_func(f:cpp.Callable<String->Int>):Void;

} // Lua


class Lua_helper {

	// -----------------------------------------------------------------------
	// hxtrace (Lua print → Haxe)
	// -----------------------------------------------------------------------

	/**
	 * Override this to redirect Lua `print()` output anywhere you like.
	 * Bug fix: the original body called `trace(s)` which recursively called
	 * itself because the field itself was named `trace`. Now delegates to
	 * `haxe.Log.trace` explicitly, or you can replace it entirely.
	 */
	public static dynamic function trace(s:String, ?inf:haxe.PosInfos):Void {
		haxe.Log.trace(s, inf);
	}

	static inline function print_function(s:String):Int {
		trace(s);
		return 0;
	}

	/** Call once after `LuaL.openlibs` to redirect Lua `print` to `Lua_helper.trace`. */
	public static inline function register_hxtrace(l:State):Void {
		Lua.register_hxtrace_func(cpp.Callable.fromStaticFunction(print_function));
		Lua.register_hxtrace_lib(l);
	}

	// -----------------------------------------------------------------------
	// Callback registry
	// -----------------------------------------------------------------------

	/** Map from Lua function name → Haxe function. */
	public static var callbacks:Map<String, Dynamic> = new Map();

	/** Register a Haxe function as a callable Lua global. */
	public static inline function add_callback(l:State, fname:String, f:Dynamic):Bool {
		callbacks.set(fname, f);
		Lua.add_callback_function(l, fname);
		return true;
	}

	/** Remove a previously registered callback. */
	public static inline function remove_callback(l:State, fname:String):Bool {
		callbacks.remove(fname);
		Lua.remove_callback_function(l, fname);
		return true;
	}

	/**
	 * Whether errors thrown inside Haxe callbacks should be forwarded to Lua
	 * as a Lua error (true) or rethrown into Haxe (false).
	 */
	public static var sendErrorsToLua:Bool = true;

	/** Internal dispatcher called from C when a registered callback is invoked. */
	public static function callback_handler(l:State, fname:String):Int {
		var cbf = callbacks.get(fname);
		if (cbf == null) return 0;

		var nparams = Lua.gettop(l);
		var args:Array<Dynamic> = [for (i in 0...nparams) Convert.fromLua(l, i + 1)];

		try {
			var ret:Dynamic = Reflect.callMethod(null, cbf, args);
			if (ret != null) {
				Convert.toLua(l, ret);
				return 1;
			}
		} catch (e:Dynamic) {
			var msg = 'CALLBACK ERROR! ${(e.message != null) ? e.message : Std.string(e)}';
			if (sendErrorsToLua) {
				LuaL.error(l, msg);
				return 0;
			}
			trace(msg);
			throw e;
		}
		return 0;
	}

}


typedef Lua_Debug = {
	@:optional var event:Int;
	@:optional var name:String;
	@:optional var namewhat:String;
	@:optional var what:String;
	@:optional var source:String;
	@:optional var currentline:Int;
	@:optional var nups:Int;
	@:optional var linedefined:Int;
	@:optional var lastlinedefined:Int;
	@:optional var short_src:Array<String>;
	@:optional var i_ci:Int;
}
#elseif hl
import llua.State;
import llua.Convert;

@:hlNative("lua")
class Lua {

    // -----------------------------------------------------------------------
    // Constants (identical to cpp target)
    // -----------------------------------------------------------------------

    public static inline var LUA_MULTRET:Int       = -1;

    public static inline var LUA_REGISTRYINDEX:Int = -10000;
    public static inline var LUA_ENVIRONINDEX:Int  = -10001;
    public static inline var LUA_GLOBALSINDEX:Int  = -10002;

    public static inline var LUA_OK:Int        = 0;
    public static inline var LUA_YIELD:Int     = 1;
    public static inline var LUA_ERRRUN:Int    = 2;
    public static inline var LUA_ERRSYNTAX:Int = 3;
    public static inline var LUA_ERRMEM:Int    = 4;
    public static inline var LUA_ERRERR:Int    = 5;

    public static inline var LUA_TNONE:Int          = -1;
    public static inline var LUA_TNIL:Int            = 0;
    public static inline var LUA_TBOOLEAN:Int        = 1;
    public static inline var LUA_TLIGHTUSERDATA:Int  = 2;
    public static inline var LUA_TNUMBER:Int         = 3;
    public static inline var LUA_TSTRING:Int         = 4;
    public static inline var LUA_TTABLE:Int          = 5;
    public static inline var LUA_TFUNCTION:Int       = 6;
    public static inline var LUA_TUSERDATA:Int       = 7;
    public static inline var LUA_TTHREAD:Int         = 8;

    public static inline var LUA_MINSTACK:Int = 20;

    public static inline var LUA_GCSTOP:Int        = 0;
    public static inline var LUA_GCRESTART:Int     = 1;
    public static inline var LUA_GCCOLLECT:Int     = 2;
    public static inline var LUA_GCCOUNT:Int       = 3;
    public static inline var LUA_GCCOUNTB:Int      = 4;
    public static inline var LUA_GCSTEP:Int        = 5;
    public static inline var LUA_GCSETPAUSE:Int    = 6;
    public static inline var LUA_GCSETSTEPMUL:Int  = 7;

    // -----------------------------------------------------------------------
    // State
    // -----------------------------------------------------------------------

    public static function close(l:State):Void {}
    public static function newthread(l:State):State { return null; }

    // -----------------------------------------------------------------------
    // Stack manipulation
    // -----------------------------------------------------------------------

    public static function gettop(l:State):Int { return 0; }
    public static function settop(l:State, idx:Int):Void {}
    public static function pushvalue(l:State, idx:Int):Void {}
    public static function remove(l:State, idx:Int):Void {}
    public static function insert(l:State, idx:Int):Void {}
    public static function replace(l:State, idx:Int):Void {}
    public static function checkstack(l:State, sz:Int):Int { return 0; }
    public static function xmove(from:State, to:State, n:Int):Void {}

    // -----------------------------------------------------------------------
    // Access (stack → Haxe)
    // -----------------------------------------------------------------------

    public static function isnumber(l:State, idx:Int):Int { return 0; }
    public static function isfunction(l:State, idx:Int):Bool { return false; }
    public static function isstring(l:State, idx:Int):Int { return 0; }
    public static function iscfunction(l:State, idx:Int):Int { return 0; }
    public static function isuserdata(l:State, idx:Int):Int { return 0; }
    public static function isboolean(l:State, idx:Int):Int { return 0; }
    public static function istable(l:State, idx:Int):Int { return 0; }
    public static function isnil(l:State, idx:Int):Int { return 0; }
    public static function isnone(l:State, idx:Int):Int { return 0; }
    public static function isnoneornil(l:State, idx:Int):Int { return 0; }
    public static function type(l:State, idx:Int):Int { return 0; }
    public static function typename(l:State, tp:Int):String { return null; }

    public static function tonumber(l:State, idx:Int):Float { return 0; }
    public static function tointeger(l:State, idx:Int):Int { return 0; }
    public static function toboolean(l:State, idx:Int):Bool { return false; }
    public static function tostring(l:State, idx:Int):String { return null; }
    public static function objlen(l:State, idx:Int):Int { return 0; }

    // -----------------------------------------------------------------------
    // Push (Haxe → stack)
    // -----------------------------------------------------------------------

    public static function pushnil(l:State):Void {}
    public static function pushnumber(l:State, n:Float):Void {}
    public static function pushinteger(l:State, n:Int):Void {}
    public static function pushstring(l:State, s:String):Void {}
    public static function pushboolean(l:State, b:Bool):Void {}
    public static function pushthread(l:State):Int { return 0; }

    // -----------------------------------------------------------------------
    // Get (Lua → stack)
    // -----------------------------------------------------------------------

    public static function gettable(l:State, idx:Int):Void {}
    public static function getfield(l:State, idx:Int, k:String):Void {}
    public static function rawget(l:State, idx:Int):Void {}
    public static function rawgeti(l:State, idx:Int, n:Int):Void {}
    public static function createtable(l:State, narr:Int, nrec:Int):Void {}
    public static function getmetatable(l:State, idx:Int):Int { return 0; }
    public static function getglobal(l:State, name:String):Void {}

    // -----------------------------------------------------------------------
    // Set (stack → Lua)
    // -----------------------------------------------------------------------

    public static function settable(l:State, idx:Int):Void {}
    public static function setfield(l:State, idx:Int, k:String):Void {}
    public static function rawset(l:State, idx:Int):Void {}
    public static function rawseti(l:State, idx:Int, n:Int):Void {}
    public static function setmetatable(l:State, idx:Int):Int { return 0; }
    public static function setglobal(l:State, name:String):Void {}

    // -----------------------------------------------------------------------
    // Load and call
    // -----------------------------------------------------------------------

    public static function call(l:State, nargs:Int, nresults:Int):Void {}
    public static function pcall(l:State, nargs:Int, nresults:Int, errfunc:Int):Int { return 0; }
    public static function lua_error(l:State):Int { return 0; }
    public static function next(l:State, idx:Int):Int { return 0; }
    public static function concat(l:State, n:Int):Void {}

    // -----------------------------------------------------------------------
    // Coroutines
    // -----------------------------------------------------------------------

    public static function yield(l:State, n:Int):Int { return 0; }
    public static function resume(l:State, narg:Int):Int { return 0; }
    public static function status(l:State):Int { return 0; }

    // -----------------------------------------------------------------------
    // GC
    // -----------------------------------------------------------------------

    public static function gc(l:State, what:Int, data:Int):Int { return 0; }

    // -----------------------------------------------------------------------
    // Misc
    // -----------------------------------------------------------------------

    public static function upvalueindex(i:Int):Int { return 0; }
    public static function pop(l:State, n:Int):Void {}
    public static function newtable(l:State):Void {}

    // -----------------------------------------------------------------------
    // Version
    // -----------------------------------------------------------------------

    @:hlNative("lua", "version")
    public static function _version():hl.Bytes { return null; }
    @:hlNative("lua", "versionjit")
    public static function _versionJIT():hl.Bytes { return null; }

	public static function version():String {
		@:privateAccess
		return String.fromUTF8(_version());
	}

	public static function versionJIT():String {
		@:privateAccess
		return String.fromUTF8(_versionJIT());
	}

    // -----------------------------------------------------------------------
    // Callback system
    // -----------------------------------------------------------------------

    public static function set_callbacks_function(f:State->String->Int):Void {}
    public static function add_callback_function(l:State, name:String):Void {}
    public static function remove_callback_function(l:State, name:String):Void {}

    static inline function init_callbacks(l:State):Void {
        set_callbacks_function(Lua_helper.callback_handler);
    }

    // -----------------------------------------------------------------------
    // hxtrace
    // -----------------------------------------------------------------------

    public static function register_hxtrace_func(f:String->Int):Void {}
    public static function register_hxtrace_lib(l:State):Void {}

    // -----------------------------------------------------------------------
    // Error handler helper
    // -----------------------------------------------------------------------

    /** Pushes the error handler onto the stack; use gettop() result as errfunc in pcall. */
    public static function set_error_handler(l:State):Void {}

    // -----------------------------------------------------------------------
    // Lua.register — same interface as cpp target
    // -----------------------------------------------------------------------

    static inline function register(l:State, name:String, f:Dynamic):Void {
        if (Type.typeof(f) == TFunction && !Lua_helper.callbacks.exists(name))
            Lua_helper.add_callback(l, name, f);
    }

}


class Lua_helper {

    // -----------------------------------------------------------------------
    // hxtrace
    // -----------------------------------------------------------------------

    public static dynamic function trace(s:String, ?inf:haxe.PosInfos):Void {
        haxe.Log.trace(s, inf);
    }

    static function print_function(s:String):Int {
        trace(s);
        return 0;
    }

    public static inline function register_hxtrace(l:State):Void {
        Lua.register_hxtrace_func(print_function);
        Lua.register_hxtrace_lib(l);
    }

    // -----------------------------------------------------------------------
    // Callback registry
    // -----------------------------------------------------------------------

    public static var callbacks:Map<String, Dynamic> = new Map();

    public static inline function add_callback(l:State, fname:String, f:Dynamic):Bool {
        callbacks.set(fname, f);
        Lua.add_callback_function(l, fname);
        return true;
    }

    public static inline function remove_callback(l:State, fname:String):Bool {
        callbacks.remove(fname);
        Lua.remove_callback_function(l, fname);
        return true;
    }

    public static var sendErrorsToLua:Bool = true;

    public static function callback_handler(l:State, fname:String):Int {
        var cbf = callbacks.get(fname);
        if (cbf == null) return 0;

        var nparams = Lua.gettop(l);
        var args:Array<Dynamic> = [for (i in 0...nparams) Convert.fromLua(l, i + 1)];

        try {
            var ret:Dynamic = Reflect.callMethod(null, cbf, args);
            if (ret != null) {
                Convert.toLua(l, ret);
                return 1;
            }
        } catch (e:Dynamic) {
            var msg = 'CALLBACK ERROR! ${(e.message != null) ? e.message : Std.string(e)}';
            if (sendErrorsToLua) {
                LuaL.error(l, msg);
                return 0;
            }
            trace(msg);
            throw e;
        }
        return 0;
    }

}


typedef Lua_Debug = {
    @:optional var event:Int;
    @:optional var name:String;
    @:optional var namewhat:String;
    @:optional var what:String;
    @:optional var source:String;
    @:optional var currentline:Int;
    @:optional var nups:Int;
    @:optional var linedefined:Int;
    @:optional var lastlinedefined:Int;
    @:optional var short_src:Array<String>;
    @:optional var i_ci:Int;
}
#end