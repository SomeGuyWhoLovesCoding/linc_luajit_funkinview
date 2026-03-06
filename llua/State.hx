package llua;


#if cpp
@:include('linc_lua.h')
@:native('::cpp::Reference<lua_State>')
extern class State {}

@:native('lua_State')
extern class Lua_State {}

typedef StatePointer = cpp.RawPointer<Lua_State>;
#elseif hl
@:hlNative("lua")
abstract State(hl.Abstract<"lua_state">) {
    inline function new(s:hl.Abstract<"lua_state">) this = s;
}
#end


// @:native("lua_State")
// @:include('linc_lua.h')
// extern private class Lua_State {}
// typedef State = cpp.Pointer<Lua_State>;
