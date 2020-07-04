package be.types;

#if macro
import haxe.macro.Expr;
import haxe.macro.Defines;
import be.types.defaulting.LocalDefines;

using tink.MacroApi;
using haxe.macro.Context;
#end

using Std;
using tink.CoreApi;

@:forward
abstract Default<T>(T) from T to T {

    public #if !debug inline #end function new(v) this = v;
    // Have to keep until a work around for https://github.com/HaxeFoundation/haxe/issues/9685 is found.
    public #if !debug inline #end function get():T return this;

    public static #if !debug inline #end function fromSafeValue<T>(v:T):Default<T> {
        return new Default<T>(v);
    }
    //public static #if !debug inline #end function of<T>(v:Null<T>, d:T):Default<T> return new Default<T>(v == null ? d : v);

    @:to public inline function toString():String return Std.string(this);


    @:from public static macro function fromNIL<T>(v:ExprOf<be.types.NIL>):ExprOf<be.types.Default<T>> {
        return fromExpr(v);
    }

    #if thx_core 
    @:from public static macro function fromThxNil<T>(v:ExprOf<thx.Nil>):ExprOf<be.types.Default<T>> {
        return fromExpr(v);
    }
    #end

    #if tink_core 
    @:from public static macro function fromTinkNil<T>(v:ExprOf<tink.core.Noise>):ExprOf<be.types.Default<T>> {
        return fromExpr(v);
    }
    #end

    #if macro
    public static function fromExpr(v:Expr):Expr {
        var value = be.macros.Default.typeToValue( Context.getExpectedType(), v.pos );
        var result = macro @:pos(v.pos) new be.types.Default($value);
        
        if (Defines.Debug && LocalDefines.DefaultVerbose) {
            trace( '---expr---' );
            trace( result.toString() );
            trace( '---####---' );

        }

        return result;
    }
    #end

}