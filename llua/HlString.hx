package llua;

#if hl
// ---------------------------------------------------------------------------
// String marshalling helper — mirrors the HlString abstract in LuaJIT.hx.
// All @:hlNative methods that cross the string boundary use this type so that
// Haxe Strings are transparently converted to/from UTF-8 bytes.
// ---------------------------------------------------------------------------
@:access(String)
abstract HlString(hl.Bytes) from hl.Bytes {
	@:from static inline function fromString(s:String):HlString {
		return s.toUtf8();
	}

	@:to inline function toString():String {
		return @:privateAccess String.fromUTF8(this);
	}
}
#end