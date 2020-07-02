package be.types;

#if (eval || macro)
import haxe.macro.Expr;
import haxe.macro.Defines;

using tink.MacroApi;
using haxe.macro.Context;
#end

using Std;
using tink.CoreApi;

@:forward
@:notNull
abstract Default<T>(T) from T to T {

    public #if !debug inline #end function new(v) this = v;

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

    #if (eval || macro)
    private static final isDebug = Defines.Debug && Context.defined('default_debug');
    public static function fromExpr(v:Expr):Expr {
        var value = be.macros.Default.typeToValue( Context.getExpectedType(), v.pos );
        var result = macro @:pos(v.pos) be.types.Default.fromSafeValue($value);
        
        if (isDebug) {
            trace( '---nil expr---' );
            trace( result.toString() );
            trace( '---####---' );

        }

        return result;
    }
    #end

}