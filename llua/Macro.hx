package llua;

import haxe.macro.Expr;

class Macro {

	/**
	 * Iterates over a Lua table at stack index `v`, executing `body` for each
	 * key-value pair. During `body`, the key is at -2 and the value at -1.
	 * The value is popped after each iteration; the key remains for `lua_next`.
	 *
	 * Handles negative indices correctly by adjusting for the extra nil pushed.
	 *
	 * Bug fix: the original `popped` flag logic attempted to pop on exception
	 * but the catch was implicit and unreliable. The new version is cleaner:
	 * we always pop exactly one value (the value half of the pair) at the end
	 * of each loop body, which is the correct Lua table-iteration protocol.
	 * The nil sentinel is consumed by lua_next returning 0.
	 */
	public static macro function loopTable(l:Expr, v:Expr, body:Expr):Expr {
		return macro {
			// Adjust negative index: pushing nil shifts the stack by 1.
			var __tbl_idx = ($v < 0) ? $v - 1 : $v;
			Lua.pushnil($l);
			while (Lua.next($l, __tbl_idx) != 0) {
				// key @ -2, value @ -1
				$body;
				Lua.pop($l, 1); // pop value; key stays for next lua_next call
			}
			// When lua_next returns 0 it has already popped the key.
		}
	}

}
