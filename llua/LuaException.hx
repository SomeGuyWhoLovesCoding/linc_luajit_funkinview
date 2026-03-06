package llua;

import llua.State;
import haxe.Exception;

class LuaException extends Exception {

	public var error_code:Int = 0;

	public function new(?message:String, ?previous:Exception, ?code:Int = 0, ?luaState:State) {
		error_code = code;
		if (message == null) {
			message = switch (code) {
				case Lua.LUA_ERRRUN:
					(luaState == null ? "Lua Runtime Error: UNKNOWN ERROR?" : Lua.tostring(luaState, -1));
				case Lua.LUA_ERRMEM:
					"luavm ran out of memory";
				case Lua.LUA_ERRERR:
					"LUA_ERRERR: error in error handler";
				default:
					"Lua Error: " + code;
			};
		}
		super(message, previous);
	}

	/**
	 * Bug fix: was called as `new LuaException(status, l)` which mapped to
	 * (message=status, previous=l) — code was never set. Now uses a static
	 * factory that passes arguments in the right positions.
	 */
	public static inline function ifErrorThrow(l:State, status:Int):Void {
		if (status == 0) return;
		throw new LuaException(null, null, status, l);
	}

}
