package llua;

/**
 * Wraps a Lua function captured from a script for use as a Haxe callback.
 *
 * Obtain via `Convert.fromLua` when the value at the stack index is a function.
 * Call `dispose()` when you no longer need the callback to release the Lua
 * registry reference and allow the function to be garbage-collected.
 */
class LuaCallback {

	/** The Lua state this function belongs to. */
	private var l:State;

	/** Registry reference key (from `luaL_ref`). */
	public var ref(default, null):Int;

	/** Whether `dispose()` has already been called. */
	private var disposed:Bool = false;

	public function new(lua:State, ref:Int) {
		this.l = lua;
		this.ref = ref;
	}

	/**
	 * Invoke this Lua function with the given Haxe arguments.
	 * Any return values from Lua are ignored; use `callWithReturn` if you need them.
	 *
	 * Does nothing if `dispose()` has already been called.
	 */
	public function call(?args:Array<Dynamic>):Void {
		if (disposed) {
			trace("LuaCallback.call() called after dispose() — ignoring.");
			return;
		}
		Lua.rawgeti(l, Lua.LUA_REGISTRYINDEX, ref);
		if (Lua.isfunction(l, -1)) {
			Lua.pop(l, 1);
			trace("LuaCallback: registry ref is no longer a function.");
			return;
		}
		if (args == null) args = [];
		for (arg in args) Convert.toLua(l, arg);
		var status = Lua.pcall(l, args.length, 0, 0);
		if (status != Lua.LUA_OK) {
			var err = Lua.tostring(l, -1);
			Lua.pop(l, 1);
			if (err == null || err == "") {
				err = switch (status) {
					case Lua.LUA_ERRRUN: "Runtime Error";
					case Lua.LUA_ERRMEM: "Memory Allocation Error";
					case Lua.LUA_ERRERR: "Critical Error in error handler";
					default: 'Unknown Error (status=$status)';
				};
			}
			trace("LuaCallback error: " + err);
		}
	}

	/**
	 * Invoke this Lua function and return all values it pushes as a Haxe Array.
	 * Throws `LuaException` on error.
	 */
	public function callWithReturn(?args:Array<Dynamic>):Array<Dynamic> {
		if (disposed) throw "LuaCallback.callWithReturn() called after dispose()";
		Lua.rawgeti(l, Lua.LUA_REGISTRYINDEX, ref);
		if (Lua.isfunction(l, -1)) {
			Lua.pop(l, 1);
			throw "LuaCallback: registry ref is no longer a function.";
		}
		if (args == null) args = [];
		for (arg in args) Convert.toLua(l, arg);
		LuaException.ifErrorThrow(l, Lua.pcall(l, args.length, Lua.LUA_MULTRET, 0));
		var nresults = Lua.gettop(l);
		var ret:Array<Dynamic> = [for (i in 0...nresults) Convert.fromLua(l, i + 1)];
		Lua.settop(l, 0);
		return ret;
	}

	/**
	 * Release the Lua registry reference.
	 * Must be called when the callback is no longer needed to avoid leaking
	 * the referenced function in the Lua registry.
	 */
	public function dispose():Void {
		if (disposed) return;
		disposed = true;
		LuaL.unref(l, Lua.LUA_REGISTRYINDEX, ref);
	}

}