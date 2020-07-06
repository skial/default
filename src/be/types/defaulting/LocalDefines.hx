package be.types.defaulting;

import haxe.macro.Defines;
import haxe.macro.Context;

enum abstract LocalDefines(Defines) {
    public var DefaultVerbose = 'default-debug';
    
    @:to public inline function asBool():Bool {
		return haxe.macro.Context.defined(this);
	}

    @:op(A == B) private static function equals(a:LocalDefines, b:Bool):Bool;
    @:op(A && B) private static function and(a:LocalDefines, b:Bool):Bool;
    @:op(A != B) private static function not(a:LocalDefines, b:Bool):Bool;
    @:op(!A) private static function negate(a:LocalDefines):Bool;
}