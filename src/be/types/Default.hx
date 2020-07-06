package be.types;

#if tink_json
import tink.json.Representation;
#end

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

    #if !debug inline #end function new(v) this = v;
    // Have to keep until a work around for https://github.com/HaxeFoundation/haxe/issues/9685 is found.
    public #if !debug inline #end function get():T return this;

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

    #if tink_json
    @:to public function toTinkRep():Representation<T> return new Representation(this);
    @:from public static function fromTinkRep<T>(v:Representation<T>):Default<T> return new Default(v.get());
    #end

    #if macro
    public static function fromExpr(v:Expr):Expr {
        var value = be.macros.Default.typeToValue( Context.getExpectedType(), v.pos );
        var result = macro @:pos(v.pos) @:privateAccess new be.types.Default($value);
        
        if (Defines.Debug && LocalDefines.DefaultVerbose) {
            trace( '---expr---' );
            trace( result.toString() );
            trace( '---####---' );

        }

        return result;
    }
    #end

}