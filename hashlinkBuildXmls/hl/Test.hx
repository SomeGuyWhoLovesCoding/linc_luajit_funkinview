import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;

class Testing {
	var x = 1;
	function die(){
		trace('no way i died');
	}
	function test() {
		trace("YAAAAAAYYYYYYYY");
	}
}


class Test {
		

	static function main() {

		var vm:State = LuaL.newstate();
		LuaL.openlibs(vm);
		var v = Lua.version();
		trace("Lua version: " + v);
		trace("LuaJIT version: " + Lua.versionJIT());

		LuaL.dofile(vm, "script.lua");



		// Lua.getglobal(vm, "foo");
		// Lua.pushinteger(vm, 1);
		// Lua.pushnumber(vm, 2.0);
		// Lua.pushstring(vm, "three");
		final testValues:Array<Dynamic> = [
			["Int", 1],
			["Float", 2.0],
			["String", "three"],
			["Array[1]", ["four"],1],
			["Map.v", ["v"=>"five"],"v"],
			["Anon.v", {"v":"six"},"v"],
		];
		trace("from haxe:");
		trace(Convert.callLuaFunction(vm,'fromHaxe',false,testValues));
		trace("to haxe:");
		trace(Convert.callLuaFunction(vm,'toHaxe',true,null));


		Convert.setGlobal(vm,"haxeValue",Testing);
		Convert.callLuaFuncNoReturns(vm,'test');
		// Convert.toLua(vm,testValues);

		// Lua.pcall(vm,Lua.gettop(vm)-1, 0, 1);
		// trace('${Convert.fromLua(vm,0)}');




		Lua.close(vm);

	}


}