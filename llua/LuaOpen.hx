package llua;

#if cpp
import llua.State;


@:include('linc_lua.h')
extern class LuaOpen {

    @:native('luaopen_base')
    static function base(l:State) : Int;

    @:native('luaopen_math')
    static function math(l:State) : Int;

    @:native('luaopen_string')
    static function string(l:State) : Int;

    @:native('luaopen_table')
    static function table(l:State) : Int;

    @:native('luaopen_io')
    static function io(l:State) : Int;

    @:native('luaopen_os')
    static function os(l:State) : Int;

    @:native('luaopen_package')
    static function lpackage(l:State) : Int; // renamed from "package"

    @:native('luaopen_debug')
    static function debug(l:State) : Int;

    @:native('luaopen_bit')
    static function bit(l:State) : Int;

    @:native('luaopen_jit')
    static function jit(l:State) : Int;

    @:native('luaopen_ffi')
    static function ffi(l:State) : Int;

} // Luaopen
#elseif hl

import llua.State;

@:hlNative("lua")
class LuaOpen {

    @:hlNative("lua", "open_base")
    static function base(l:State):Int { return 0; }

    @:hlNative("lua", "open_math")
    static function math(l:State):Int { return 0; }

    @:hlNative("lua", "open_string")
    static function string(l:State):Int { return 0; }

    @:hlNative("lua", "open_table")
    static function table(l:State):Int { return 0; }

    @:hlNative("lua", "open_io")
    static function io(l:State):Int { return 0; }

    @:hlNative("lua", "open_os")
    static function os(l:State):Int { return 0; }

    @:hlNative("lua", "open_package")
    static function lpackage(l:State):Int { return 0; }

    @:hlNative("lua", "open_debug")
    static function debug(l:State):Int { return 0; }

    @:hlNative("lua", "open_bit")
    static function bit(l:State):Int { return 0; }

    @:hlNative("lua", "open_jit")
    static function jit(l:State):Int { return 0; }

    @:hlNative("lua", "open_ffi")
    static function ffi(l:State):Int { return 0; }

}
