package llua;

#if cpp
import llua.State;
import llua.Buffer;
import llua.Lua;

@:include('linc_lua.h')
extern class LuaL {


    // @:native('luaL_register')
    // static function register(l:State, libname:String, lr:luaL_Reg) : Void;

    @:native('luaL_getmetafield')
    static function getmetafield(l:State, obj:Int, e:String) : Int;

    @:native('luaL_callmeta')
    static function callmeta(l:State, obj:Int, e:String) : Int;

    @:native('luaL_typerror')
    static function typerror(l:State, narg:Int, tname:String) : Int;

    @:native('luaL_argerror')
    static function argerror(l:State, narg:Int, extramsg:String) : Int;

    @:native('linc::lual::error')
    static function error(l:State, fmt:String) : Int;

    @:native('linc::lual::checklstring')
    static function checklstring(l:State, narg:Int, l:UInt) : String;

    @:native('linc::lual::optlstring')
    static function optlstring(l:State, narg:Int, d:String, l:UInt) : String;

    @:native('luaL_checknumber')
    static function checknumber(l:State, narg:Int) : Float;

    @:native('luaL_optnumber')
    static function optnumber(l:State, narg:Int, d:Float) : Float;

    @:native('luaL_checkinteger')
    static function checkinteger(l:State, narg:Int) : Int;

    @:native('luaL_optinteger')
    static function optinteger(l:State, narg:Int, d:Int) : Int;

    @:native('luaL_checkstack')
    static function checkstack(l:State, sz:Int, msg:String) : Void;

    @:native('luaL_checktype')
    static function checktype(l:State, narg:Int, t:Int) : Void;

    static inline function checktable(l:State, idx:Int) : Void {
      return checktype(l,idx,Lua.LUA_TTABLE);
    }

    @:native('luaL_checkany')
    static function checkany(l:State, narg:Int) : Void;

    @:native('luaL_newmetatable')
    static function newmetatable(l:State, tname:String) : Int;

    @:native('luaL_checkudata')
    static function checkudata(l:State, narg:Int, tname:String) : Void;

    @:native('luaL_where')
    static function where(l:State, lvl:Int) : Void;

    // @:native('luaL_error')
    // static function error(l:State, fmt:String, ...) : Int;

    @:native('luaL_checkoption')
    static function checkoption(l:State, narg:Int, def:String, const:Array<String>) : Int;

    @:native('luaL_ref')
    static function ref(l:State, t:Int) : Int;

    @:native('luaL_unref')
    static function unref(l:State, t:Int, ref:Int) : Void;

    @:native('luaL_loadfile')
    static function loadfile(l:State, filename:String) : Int;

    @:native('luaL_loadbuffer')
    static function loadbuffer(l:State, buff:String, sz:Int, name:String) : Int;

    @:native('luaL_loadstring')
    static function loadstring(l:State, s:String) : Int;

    @:native('luaL_newstate')
    static function newstate() : State;

    @:native('linc::lual::gsub')
    static function gsub(l:State, s:String, p:String, r:String) : String;

    @:native('linc::lual::findtable')
    static function findtable(l:State, idx:Int, fname:String, szhint:Int) : String;


    /* From Lua 5.2. */

    @:native('luaL_fileresult')
    static function fileresult(l:State, stat:Int, tname:String) : Int;

    @:native('luaL_execresult')
    static function execresult(l:State, stat:Int) : Int;

    @:native('luaL_loadfilex')
    static function loadfilex(l:State, filename:String, mode:String) : Int;

    @:native('luaL_loadbufferx')
    static function loadbufferx(l:State, buff:String, sz:Int, name:String, mode:String) : Int;

    @:native('luaL_traceback')
    static function traceback(l:State, l2:State, msg:String, level:Int) : Void;

    /*
    ** ===============================================================
    ** some useful macros
    ** ===============================================================
    */

    @:native('luaL_argcheck')
    static function argcheck(l:State, cond:Int, narg:Int, extramsg:String) : Void;

    @:native('linc::lual::checkstring')
    static function checkstring(l:State, narg:Int) : String;

    @:native('linc::lual::optstring')
    static function optstring(l:State, narg:Int, d:String) : String;

    @:native('luaL_checkint')
    static function checkint(l:State, narg:Int) : Int;

    @:native('luaL_optint')
    static function optint(l:State, narg:Int, d:Int) : Int;

    @:native('luaL_checklong')
    static function checklong(l:State, narg:Int) : Float;

    @:native('luaL_optlong')
    static function optlong(l:State, narg:Int, d:Float) : Float;

    @:native('linc::lual::ltypename')
    static function typename(l:State, index:Int) : String;

    @:native('luaL_dofile')
    static function dofile(l:State, filename:String) : Int;

    @:native('luaL_dostring')
    static function dostring(l:State, str:String) : Int;

    @:native('luaL_getmetatable')
    static function getmetatable(l:State, tname:String) : Void;


    /*
    ** {======================================================
    ** Generic Buffer manipulation
    ** =======================================================
    */

    @:native('luaL_addchar')
    static function addchar(b:BufferRef, c:String) : Void;

    /* compatibility only */
    @:native('luaL_putchar')
    static function putchar(b:BufferRef, c:String) : Void;

    @:native('luaL_addsize')
    static function addsize(b:BufferRef, n:Int) : Void;

    @:native('luaL_buffinit')
    static function buffinit(l:State, b:BufferRef) : Void; // example: var b:Buffer = null; LuaL.buffinit(l, cast b);

    @:native('linc::lual::prepbuffer')
    static function prepbuffer(b:BufferRef) : String;

    @:native('luaL_addlstring')
    static function addlstring(b:BufferRef, s:String, l:Int) : Void;

    @:native('luaL_addstring')
    static function addstring(b:BufferRef, s:String) : Void;

    @:native('luaL_addvalue')
    static function addvalue(b:BufferRef) : Void;

    @:native('luaL_pushresult')
    static function pushresult(b:BufferRef) : Void;



    /* }====================================================== */


    /* compatibility with ref system */

    /* predefined references */
    public static inline var LUA_NOREF:Int   = (-2);
    public static inline var LUA_REFNIL:Int  = (-1);


    @:native('luaL_openlibs')
    static function openlibs(l:State) : Void;

} //LuaL
#elseif hl
import llua.State;
import llua.Lua;

@:hlNative("lua")
class LuaL {

    @:hlNative("lua", "lual_dofile")
    public static function dofile(l:State, filename:String):Int { return 0; }

    @:hlNative("lua", "lual_dostring")
    public static function dostring(l:State, s:String):Int { return 0; }

    @:hlNative("lua", "lual_loadfile")
    public static function loadfile(l:State, filename:String):Int { return 0; }

    @:hlNative("lua", "lual_loadstring")
    public static function loadstring(l:State, s:String):Int { return 0; }

    @:hlNative("lua", "lual_openlibs")
    public static function openlibs(l:State):Void {}

    @:hlNative("lua", "lual_ref")
    public static function ref(l:State, t:Int):Int { return 0; }

    @:hlNative("lua", "lual_unref")
    public static function unref(l:State, t:Int, ref:Int):Void {}

    @:hlNative("lua", "lual_where")
    public static function where(l:State, lvl:Int):Void {}

    @:hlNative("lua", "lual_newmetatable")
    public static function newmetatable(l:State, tname:String):Int { return 0; }

    @:hlNative("lua", "lual_error")
    public static function error(l:State, fmt:String):Int { return 0; }

    @:hlNative("lua", "lual_typename")
    public static function typename(l:State, index:Int):String { return null; }

    @:hlNative("lua", "lual_checknumber")
    public static function checknumber(l:State, narg:Int):Float { return 0; }

    @:hlNative("lua", "lual_checkinteger")
    public static function checkinteger(l:State, narg:Int):Int { return 0; }

    @:hlNative("lua", "lual_checkstring")
    public static function checkstring(l:State, narg:Int):String { return null; }

    @:hlNative("lua", "lual_checktype")
    public static function checktype(l:State, narg:Int, t:Int):Void {}

    static inline function checktable(l:State, idx:Int):Void {
        checktype(l, idx, Lua.LUA_TTABLE);
    }

    @:hlNative("lua", "lual_checkany")
    public static function checkany(l:State, narg:Int):Void {}

    @:hlNative("lua", "lual_argerror")
    public static function argerror(l:State, narg:Int, extramsg:String):Int { return 0; }

    @:hlNative("lua", "lual_traceback")
    public static function traceback(l:State, l2:State, msg:String, level:Int):Void {}

    @:hlNative("lua", "newstate")
    public static function newstate():State { return null; }

    /* predefined references */
    public static inline var LUA_NOREF:Int  = -2;
    public static inline var LUA_REFNIL:Int = -1;

}
#end