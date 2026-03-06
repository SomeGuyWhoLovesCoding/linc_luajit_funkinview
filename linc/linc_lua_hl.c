/**
 * linc_lua_hl.c
 * HashLink (.hdll) native bindings for LuaJIT.
 *
 * Must be compiled as C (not C++). The build XML entry must use a .c extension.
 * HL_NAME is redefined to "hlua_" prefix to avoid clashing with the real
 * lua_* symbols declared extern "C" in lua.h / lua.hpp.
 */

#undef  HL_NAME
#define HL_NAME(n) hlua_##n

#include <hl.h>
#include "../lib/lua/src/lua.hpp"

/* hl_to_utf8 expects const uchar*; vbyte* needs a cast */
#define HL_STR(s) ((const uchar*)(s))

// ---------------------------------------------------------------------------
// Internal: callback dispatcher
// ---------------------------------------------------------------------------

static vclosure *hl_callback_fn = NULL;

static int hl_lua_callback_dispatcher(lua_State *L) {
    if (!hl_callback_fn) return 0;
    const char *name = lua_tostring(L, lua_upvalueindex(1));
    vdynamic arg_state; arg_state.t = &hlt_abstract; arg_state.v.ptr = L;
    vdynamic arg_name;  arg_name.t  = &hlt_bytes;    arg_name.v.ptr  = (void*)hl_to_utf16(name);
    vdynamic *args[2] = { &arg_state, &arg_name };
    vdynamic *ret = hl_dyn_call(hl_callback_fn, args, 2);
    return ret ? ret->v.i : 0;
}

// ---------------------------------------------------------------------------
// Internal: hxtrace (Lua print → Haxe)
// ---------------------------------------------------------------------------

static vclosure *hl_trace_fn = NULL;

static int hl_lua_print(lua_State *L) {
    if (!hl_trace_fn) return 0;
    int n = lua_gettop(L);
    luaL_Buffer b;
    luaL_buffinit(L, &b);
    lua_getglobal(L, "tostring");
    int i;
    for (i = 1; i <= n; i++) {
        size_t len;
        const char *s;
        lua_pushvalue(L, -1);
        lua_pushvalue(L, i);
        lua_call(L, 1, 1);
        s = lua_tolstring(L, -1, &len);
        if (!s) luaL_error(L, "'tostring' must return a string");
        if (i > 1) luaL_addstring(&b, "\t");
        luaL_addlstring(&b, s, len);
        lua_pop(L, 1);
    }
    luaL_pushresult(&b);
    {
        const char *out = lua_tostring(L, -1);
        lua_pop(L, 1);
        vdynamic arg; arg.t = &hlt_bytes; arg.v.ptr = (void*)hl_to_utf16(out);
        vdynamic *args[1] = { &arg };
        hl_dyn_call(hl_trace_fn, args, 1);
    }
    return 0;
}

static const luaL_Reg hl_printlib[] = {
    {"print", hl_lua_print},
    {NULL, NULL}
};

// ---------------------------------------------------------------------------
// Internal: error handler
// ---------------------------------------------------------------------------

static int hl_on_error(lua_State *L) {
    const char *msg = lua_tostring(L, 1);
    if (msg)
        luaL_traceback(L, L, msg, 1);
    else if (!lua_isnoneornil(L, 1))
        if (!luaL_callmeta(L, 1, "__tostring"))
            lua_pushliteral(L, "(no error message)");
    return 1;
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

HL_PRIM lua_State *HL_NAME(newstate)()                  { return luaL_newstate(); }
HL_PRIM void       HL_NAME(close)(lua_State *L)          { lua_close(L); }
HL_PRIM lua_State *HL_NAME(newthread)(lua_State *L)      { return lua_newthread(L); }

DEFINE_PRIM(_ABSTRACT(lua_state), newstate,  _NO_ARG);
DEFINE_PRIM(_VOID,                close,     _ABSTRACT(lua_state));
DEFINE_PRIM(_ABSTRACT(lua_state), newthread, _ABSTRACT(lua_state));

// ---------------------------------------------------------------------------
// Stack manipulation
// ---------------------------------------------------------------------------

HL_PRIM int  HL_NAME(gettop)(lua_State *L)               { return lua_gettop(L); }
HL_PRIM void HL_NAME(settop)(lua_State *L, int i)        { lua_settop(L, i); }
HL_PRIM void HL_NAME(pushvalue)(lua_State *L, int i)     { lua_pushvalue(L, i); }
HL_PRIM void HL_NAME(remove)(lua_State *L, int i)        { lua_remove(L, i); }
HL_PRIM void HL_NAME(insert)(lua_State *L, int i)        { lua_insert(L, i); }
HL_PRIM void HL_NAME(replace)(lua_State *L, int i)       { lua_replace(L, i); }
HL_PRIM int  HL_NAME(checkstack)(lua_State *L, int sz)   { return lua_checkstack(L, sz); }
HL_PRIM void HL_NAME(xmove)(lua_State *f, lua_State *t, int n) { lua_xmove(f, t, n); }

DEFINE_PRIM(_I32,  gettop,      _ABSTRACT(lua_state));
DEFINE_PRIM(_VOID, settop,      _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, pushvalue,   _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, remove,      _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, insert,      _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, replace,     _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,  checkstack,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, xmove,       _ABSTRACT(lua_state) _ABSTRACT(lua_state) _I32);

// ---------------------------------------------------------------------------
// Access — predicates return int (Lua ABI); DEFINE_PRIM maps to _BOOL for HL
// ---------------------------------------------------------------------------

HL_PRIM int HL_NAME(isnumber)(lua_State *L, int i)    { return lua_isnumber(L, i); }
HL_PRIM int HL_NAME(isfunction)(lua_State *L, int i)  { return lua_isfunction(L, i); }
HL_PRIM int HL_NAME(isstring)(lua_State *L, int i)    { return lua_isstring(L, i); }
HL_PRIM int HL_NAME(iscfunction)(lua_State *L, int i) { return lua_iscfunction(L, i); }
HL_PRIM int HL_NAME(isuserdata)(lua_State *L, int i)  { return lua_isuserdata(L, i); }
HL_PRIM int HL_NAME(isboolean)(lua_State *L, int i)   { return lua_isboolean(L, i); }
HL_PRIM int HL_NAME(istable)(lua_State *L, int i)     { return lua_istable(L, i); }
HL_PRIM int HL_NAME(isnil)(lua_State *L, int i)       { return lua_isnil(L, i); }
HL_PRIM int HL_NAME(isnone)(lua_State *L, int i)      { return lua_isnone(L, i); }
HL_PRIM int HL_NAME(isnoneornil)(lua_State *L, int i) { return lua_isnoneornil(L, i); }

DEFINE_PRIM(_BOOL, isnumber,    _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, isfunction,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, isstring,    _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, iscfunction, _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, isuserdata,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, isboolean,   _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, istable,     _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, isnil,       _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, isnone,      _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL, isnoneornil, _ABSTRACT(lua_state) _I32);

HL_PRIM int    HL_NAME(type)(lua_State *L, int i)     { return lua_type(L, i); }
HL_PRIM vbyte *HL_NAME(typename)(lua_State *L, int t) { return (vbyte*)hl_to_utf16(lua_typename(L, t)); }
HL_PRIM double HL_NAME(tonumber)(lua_State *L, int i) { return (double)lua_tonumber(L, i); }
HL_PRIM int    HL_NAME(tointeger)(lua_State *L, int i){ return (int)lua_tointeger(L, i); }
HL_PRIM int    HL_NAME(toboolean)(lua_State *L, int i){ return lua_toboolean(L, i); }
HL_PRIM int    HL_NAME(objlen)(lua_State *L, int i)   { return (int)lua_objlen(L, i); }

HL_PRIM vbyte *HL_NAME(tostring)(lua_State *L, int i) {
    const char *s = lua_tostring(L, i);
    return s ? (vbyte*)hl_to_utf16(s) : NULL;
}

DEFINE_PRIM(_I32,   type,      _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BYTES, typename,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_F64,   tonumber,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,   tointeger, _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BOOL,  toboolean, _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BYTES, tostring,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,   objlen,    _ABSTRACT(lua_state) _I32);

// ---------------------------------------------------------------------------
// Push
// ---------------------------------------------------------------------------

HL_PRIM void HL_NAME(pushnil)(lua_State *L)             { lua_pushnil(L); }
HL_PRIM void HL_NAME(pushnumber)(lua_State *L, double n){ lua_pushnumber(L, (lua_Number)n); }
HL_PRIM void HL_NAME(pushinteger)(lua_State *L, int n)  { lua_pushinteger(L, (lua_Integer)n); }
HL_PRIM void HL_NAME(pushboolean)(lua_State *L, int b)  { lua_pushboolean(L, b); }
HL_PRIM int  HL_NAME(pushthread)(lua_State *L)          { return lua_pushthread(L); }

HL_PRIM void HL_NAME(pushstring)(lua_State *L, vbyte *s) {
    lua_pushstring(L, hl_to_utf8(HL_STR(s)));
}

DEFINE_PRIM(_VOID, pushnil,     _ABSTRACT(lua_state));
DEFINE_PRIM(_VOID, pushnumber,  _ABSTRACT(lua_state) _F64);
DEFINE_PRIM(_VOID, pushinteger, _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, pushstring,  _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_VOID, pushboolean, _ABSTRACT(lua_state) _BOOL);
DEFINE_PRIM(_I32,  pushthread,  _ABSTRACT(lua_state));

// ---------------------------------------------------------------------------
// Get
// ---------------------------------------------------------------------------

HL_PRIM void HL_NAME(gettable)(lua_State *L, int i)    { lua_gettable(L, i); }
HL_PRIM void HL_NAME(rawget)(lua_State *L, int i)      { lua_rawget(L, i); }
HL_PRIM void HL_NAME(rawgeti)(lua_State *L, int i, int n) { lua_rawgeti(L, i, n); }
HL_PRIM void HL_NAME(createtable)(lua_State *L, int a, int r) { lua_createtable(L, a, r); }
HL_PRIM int  HL_NAME(getmetatable)(lua_State *L, int i){ return lua_getmetatable(L, i); }

HL_PRIM void HL_NAME(getfield)(lua_State *L, int i, vbyte *k) {
    lua_getfield(L, i, hl_to_utf8(HL_STR(k)));
}
HL_PRIM void HL_NAME(getglobal)(lua_State *L, vbyte *name) {
    lua_getglobal(L, hl_to_utf8(HL_STR(name)));
}

DEFINE_PRIM(_VOID, gettable,    _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, getfield,    _ABSTRACT(lua_state) _I32 _BYTES);
DEFINE_PRIM(_VOID, rawget,      _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, rawgeti,     _ABSTRACT(lua_state) _I32 _I32);
DEFINE_PRIM(_VOID, createtable, _ABSTRACT(lua_state) _I32 _I32);
DEFINE_PRIM(_I32,  getmetatable,_ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, getglobal,   _ABSTRACT(lua_state) _BYTES);

// ---------------------------------------------------------------------------
// Set
// ---------------------------------------------------------------------------

HL_PRIM void HL_NAME(settable)(lua_State *L, int i)    { lua_settable(L, i); }
HL_PRIM void HL_NAME(rawset)(lua_State *L, int i)      { lua_rawset(L, i); }
HL_PRIM void HL_NAME(rawseti)(lua_State *L, int i, int n) { lua_rawseti(L, i, n); }
HL_PRIM int  HL_NAME(setmetatable)(lua_State *L, int i){ return lua_setmetatable(L, i); }

HL_PRIM void HL_NAME(setfield)(lua_State *L, int i, vbyte *k) {
    lua_setfield(L, i, hl_to_utf8(HL_STR(k)));
}
HL_PRIM void HL_NAME(setglobal)(lua_State *L, vbyte *name) {
    lua_setglobal(L, hl_to_utf8(HL_STR(name)));
}

DEFINE_PRIM(_VOID, settable,    _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, setfield,    _ABSTRACT(lua_state) _I32 _BYTES);
DEFINE_PRIM(_VOID, rawset,      _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, rawseti,     _ABSTRACT(lua_state) _I32 _I32);
DEFINE_PRIM(_I32,  setmetatable,_ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, setglobal,   _ABSTRACT(lua_state) _BYTES);

// ---------------------------------------------------------------------------
// Load / call / misc
// ---------------------------------------------------------------------------

HL_PRIM void HL_NAME(call)(lua_State *L, int a, int r)         { lua_call(L, a, r); }
HL_PRIM int  HL_NAME(pcall)(lua_State *L, int a, int r, int e) { return lua_pcall(L, a, r, e); }
HL_PRIM int  HL_NAME(lua_error)(lua_State *L)                  { return lua_error(L); }
HL_PRIM int  HL_NAME(next)(lua_State *L, int i)                { return lua_next(L, i); }
HL_PRIM void HL_NAME(concat)(lua_State *L, int n)              { lua_concat(L, n); }
HL_PRIM int  HL_NAME(yield)(lua_State *L, int n)               { return lua_yield(L, n); }
HL_PRIM int  HL_NAME(resume)(lua_State *L, int n)              { return lua_resume(L, n); }
HL_PRIM int  HL_NAME(status)(lua_State *L)                     { return lua_status(L); }
HL_PRIM int  HL_NAME(gc)(lua_State *L, int w, int d)           { return lua_gc(L, w, d); }
HL_PRIM int  HL_NAME(upvalueindex)(int i)                      { return lua_upvalueindex(i); }
HL_PRIM void HL_NAME(pop)(lua_State *L, int n)                 { lua_pop(L, n); }
HL_PRIM void HL_NAME(newtable)(lua_State *L)                   { lua_newtable(L); }

DEFINE_PRIM(_VOID, call,         _ABSTRACT(lua_state) _I32 _I32);
DEFINE_PRIM(_I32,  pcall,        _ABSTRACT(lua_state) _I32 _I32 _I32);
DEFINE_PRIM(_I32,  lua_error,    _ABSTRACT(lua_state));
DEFINE_PRIM(_I32,  next,         _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, concat,       _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,  yield,        _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,  resume,       _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,  status,       _ABSTRACT(lua_state));
DEFINE_PRIM(_I32,  gc,           _ABSTRACT(lua_state) _I32 _I32);
DEFINE_PRIM(_I32,  upvalueindex, _I32);
DEFINE_PRIM(_VOID, pop,          _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID, newtable,     _ABSTRACT(lua_state));

// ---------------------------------------------------------------------------
// luaL
// ---------------------------------------------------------------------------

HL_PRIM int HL_NAME(lual_dofile)(lua_State *L, vbyte *f)  { return luaL_dofile(L, hl_to_utf8(HL_STR(f))); }
HL_PRIM int HL_NAME(lual_dostring)(lua_State *L, vbyte *s){ return luaL_dostring(L, hl_to_utf8(HL_STR(s))); }
HL_PRIM int HL_NAME(lual_loadfile)(lua_State *L, vbyte *f){ return luaL_loadfile(L, hl_to_utf8(HL_STR(f))); }
HL_PRIM int HL_NAME(lual_loadstring)(lua_State *L, vbyte *s){ return luaL_loadstring(L, hl_to_utf8(HL_STR(s))); }
HL_PRIM void HL_NAME(lual_openlibs)(lua_State *L)         { luaL_openlibs(L); }
HL_PRIM int  HL_NAME(lual_ref)(lua_State *L, int t)       { return luaL_ref(L, t); }
HL_PRIM void HL_NAME(lual_unref)(lua_State *L, int t, int r){ luaL_unref(L, t, r); }
HL_PRIM void HL_NAME(lual_where)(lua_State *L, int lvl)   { luaL_where(L, lvl); }
HL_PRIM int  HL_NAME(lual_newmetatable)(lua_State *L, vbyte *n){ return luaL_newmetatable(L, hl_to_utf8(HL_STR(n))); }
HL_PRIM double HL_NAME(lual_checknumber)(lua_State *L, int n) { return (double)luaL_checknumber(L, n); }
HL_PRIM int    HL_NAME(lual_checkinteger)(lua_State *L, int n){ return (int)luaL_checkinteger(L, n); }
HL_PRIM void   HL_NAME(lual_checktype)(lua_State *L, int n, int t){ luaL_checktype(L, n, t); }
HL_PRIM void   HL_NAME(lual_checkany)(lua_State *L, int n){ luaL_checkany(L, n); }

HL_PRIM void HL_NAME(lual_error)(lua_State *L, vbyte *msg) {
    luaL_error(L, "%s", hl_to_utf8(HL_STR(msg)));
}
HL_PRIM vbyte *HL_NAME(lual_typename)(lua_State *L, int i) {
    return (vbyte*)hl_to_utf16(luaL_typename(L, i));
}
HL_PRIM vbyte *HL_NAME(lual_checkstring)(lua_State *L, int n) {
    return (vbyte*)hl_to_utf16(luaL_checkstring(L, n));
}
HL_PRIM int HL_NAME(lual_argerror)(lua_State *L, int n, vbyte *msg) {
    return luaL_argerror(L, n, hl_to_utf8(HL_STR(msg)));
}
HL_PRIM void HL_NAME(lual_traceback)(lua_State *L, lua_State *L2, vbyte *msg, int lv) {
    luaL_traceback(L, L2, hl_to_utf8(HL_STR(msg)), lv);
}

DEFINE_PRIM(_I32,   lual_dofile,       _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_I32,   lual_dostring,     _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_I32,   lual_loadfile,     _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_I32,   lual_loadstring,   _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_VOID,  lual_openlibs,     _ABSTRACT(lua_state));
DEFINE_PRIM(_I32,   lual_ref,          _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID,  lual_unref,        _ABSTRACT(lua_state) _I32 _I32);
DEFINE_PRIM(_VOID,  lual_where,        _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,   lual_newmetatable, _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_VOID,  lual_error,        _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_BYTES, lual_typename,     _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_F64,   lual_checknumber,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,   lual_checkinteger, _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_BYTES, lual_checkstring,  _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_VOID,  lual_checktype,    _ABSTRACT(lua_state) _I32 _I32);
DEFINE_PRIM(_VOID,  lual_checkany,     _ABSTRACT(lua_state) _I32);
DEFINE_PRIM(_I32,   lual_argerror,     _ABSTRACT(lua_state) _I32 _BYTES);
DEFINE_PRIM(_VOID,  lual_traceback,    _ABSTRACT(lua_state) _ABSTRACT(lua_state) _BYTES _I32);

// ---------------------------------------------------------------------------
// LuaOpen
// ---------------------------------------------------------------------------

HL_PRIM int HL_NAME(open_base)(lua_State *L)    { return luaopen_base(L); }
HL_PRIM int HL_NAME(open_math)(lua_State *L)    { return luaopen_math(L); }
HL_PRIM int HL_NAME(open_string)(lua_State *L)  { return luaopen_string(L); }
HL_PRIM int HL_NAME(open_table)(lua_State *L)   { return luaopen_table(L); }
HL_PRIM int HL_NAME(open_io)(lua_State *L)      { return luaopen_io(L); }
HL_PRIM int HL_NAME(open_os)(lua_State *L)      { return luaopen_os(L); }
HL_PRIM int HL_NAME(open_package)(lua_State *L) { return luaopen_package(L); }
HL_PRIM int HL_NAME(open_debug)(lua_State *L)   { return luaopen_debug(L); }
HL_PRIM int HL_NAME(open_bit)(lua_State *L)     { return luaopen_bit(L); }
HL_PRIM int HL_NAME(open_jit)(lua_State *L)     { return luaopen_jit(L); }
HL_PRIM int HL_NAME(open_ffi)(lua_State *L)     { return luaopen_ffi(L); }

DEFINE_PRIM(_I32, open_base,    _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_math,    _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_string,  _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_table,   _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_io,      _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_os,      _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_package, _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_debug,   _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_bit,     _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_jit,     _ABSTRACT(lua_state));
DEFINE_PRIM(_I32, open_ffi,     _ABSTRACT(lua_state));

// ---------------------------------------------------------------------------
// LuaJIT
// ---------------------------------------------------------------------------

HL_PRIM int HL_NAME(jit_setmode)(lua_State *L, int i, int m) { return luaJIT_setmode(L, i, m); }
DEFINE_PRIM(_I32, jit_setmode, _ABSTRACT(lua_state) _I32 _I32);

// ---------------------------------------------------------------------------
// Version
// ---------------------------------------------------------------------------

HL_PRIM vbyte *HL_NAME(version)()    { return (vbyte*)hl_to_utf16(LUA_VERSION); }
HL_PRIM vbyte *HL_NAME(versionjit)() { return (vbyte*)hl_to_utf16(LUAJIT_VERSION); }

DEFINE_PRIM(_BYTES, version,    _NO_ARG);
DEFINE_PRIM(_BYTES, versionjit, _NO_ARG);

// ---------------------------------------------------------------------------
// Callback system
// ---------------------------------------------------------------------------

HL_PRIM void HL_NAME(set_callbacks_function)(vclosure *fn) {
    if (hl_callback_fn) hl_remove_root((vdynamic**)&hl_callback_fn);
    hl_callback_fn = fn;
    if (fn) hl_add_root((vdynamic**)&hl_callback_fn);
}
HL_PRIM void HL_NAME(add_callback_function)(lua_State *L, vbyte *name) {
    const char *n = hl_to_utf8(HL_STR(name));
    lua_pushstring(L, n);
    lua_pushcclosure(L, hl_lua_callback_dispatcher, 1);
    lua_setglobal(L, n);
}
HL_PRIM void HL_NAME(remove_callback_function)(lua_State *L, vbyte *name) {
    lua_pushnil(L);
    lua_setglobal(L, hl_to_utf8(HL_STR(name)));
}

DEFINE_PRIM(_VOID, set_callbacks_function,   _FUN(_I32, _ABSTRACT(lua_state) _BYTES));
DEFINE_PRIM(_VOID, add_callback_function,    _ABSTRACT(lua_state) _BYTES);
DEFINE_PRIM(_VOID, remove_callback_function, _ABSTRACT(lua_state) _BYTES);

// ---------------------------------------------------------------------------
// hxtrace
// ---------------------------------------------------------------------------

HL_PRIM void HL_NAME(register_hxtrace_func)(vclosure *fn) {
    if (hl_trace_fn) hl_remove_root((vdynamic**)&hl_trace_fn);
    hl_trace_fn = fn;
    if (fn) hl_add_root((vdynamic**)&hl_trace_fn);
}
HL_PRIM void HL_NAME(register_hxtrace_lib)(lua_State *L) {
    lua_getglobal(L, "_G");
    luaL_register(L, NULL, hl_printlib);
    lua_pop(L, 1);
}

DEFINE_PRIM(_VOID, register_hxtrace_func, _FUN(_I32, _BYTES));
DEFINE_PRIM(_VOID, register_hxtrace_lib,  _ABSTRACT(lua_state));

// ---------------------------------------------------------------------------
// Error handler helper
// ---------------------------------------------------------------------------

HL_PRIM void HL_NAME(set_error_handler)(lua_State *L) {
    lua_pushcfunction(L, hl_on_error);
}
DEFINE_PRIM(_VOID, set_error_handler, _ABSTRACT(lua_state));