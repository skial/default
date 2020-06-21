package be.types;

import tink.json.Representation;

#if (eval || macro)
using tink.MacroApi;
using haxe.macro.Context;
#end

using Std;
using tink.CoreApi;

@:forward private abstract Safe<T>(T) {
    public #if !debug inline #end function new(v) this = v;
    @:to public #if !debug inline #end function get():T return this;
    public static #if !debug inline #end function of<T>(v:T):Safe<T> return new Safe<T>(v);
}

@:forward private abstract Unsafe<T>(T) {
    public #if !debug inline #end function new(v) this = v;
    @:to public #if !debug inline #end function get():T return this;
    public static #if !debug inline #end function of<T>(v:Null<T>, d:T):Unsafe<T> return new Unsafe<T>(v == null ? d : v);
}

@:forward
@:notNull
abstract Default<T>(T) from T {

    public #if !debug inline #end function new(v) this = v;

    public #if !debug inline #end function get():T return this;

    public static #if !debug inline #end function fromSafeValue<T>(v:T):Default<T> return new Default<T>(v);
    public static #if !debug inline #end function of<T>(v:Null<T>, d:T):Default<T> return new Default<T>(v == null ? d : v);

    @:from public static #if !debug inline #end function fromUnsafeString(v:String):Default<String> return of(v, '');
    @:from public static #if !debug inline #end function fromUnsafeInt(v:Int):Default<Int> return of(v, 0);
    @:from public static #if !debug inline #end function fromUnsafeFloat(v:Float):Default<Float> return of(v, .0);
    @:from public static #if !debug inline #end function fromUnsafeBool(v:Bool):Default<Bool> return of(v, false);
    @:from public static #if !debug inline #end function fromUnsafeArray<T>(v:Array<T>):Default<Array<T>> return of(v, []);
    @:from public static #if !debug inline #end function fromUnsafeObject(v:{}):Default<{}> return of(v, {});

    @:to public static #if !debug inline #end function asDefaultString(v:Safe<String>):Default<String> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultInt(v:Safe<Int>):Default<Int> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultFloat(v:Safe<Float>):Default<Float> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultBool(v:Safe<Bool>):Default<Bool> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultArray<T>(v:Safe<Array<T>>):Default<Array<T>> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultStringlyArray<T>(v:Safe<Array<T>>):Default<String> return new Default('' + v);
    @:to public static #if !debug inline #end function asDefaultObject(v:Safe<{}>):Default<{}> return new Default(v.get());

    @:to public static #if !debug inline #end function asString(v:String):String return #if !static (v == null ? '' : v) #else v #end;
    @:to public static #if !debug inline #end function asInt(v:Int):Int return #if !static (v == null ? 0 : v) #else v #end;
    @:to public static #if !debug inline #end function asFloat(v:Float):Float return #if !static (v == null ? .0 : v) #else v #end;
    @:to public static #if !debug inline #end function asBool(v:Bool):Bool return #if !static (v == null ? false : v) #else v #end;
    @:to public static #if !debug inline #end function asArray<T>(v:Array<T>):Array<T> return #if !static (v == null ? [] : v) #else v #end;
    @:to public static #if !debug inline #end function asStringlyArray<T>(v:Array<T>):String return '' + #if !static (v == null ? [] : v) #else v #end;
    @:to public static #if !debug inline #end function asObject(v:{}):{} return #if !static (v == null ? {} : v) #else v #end;

    @:to public inline function toString():String return Std.string(this);
    /*#if !static
    @:to public function toTinkRep():Representation<T> return new Representation(this);
    @:from public static function fromTinkRep<T>(v:Representation<T>):Default<T> return new Default(v.get());
    #end*/

    @:from public static macro function fromNIL<T>(v:ExprOf<be.types.NIL>):ExprOf<be.types.Default<T>> {
        var value = be.macros.Default.typeToValue( Context.getExpectedType(), v.pos );
        var result = macro @:pos(v.pos) be.types.Default.fromSafeValue($e{value});
        
        if (isDebug) {
            trace( '---expr---' );
            trace( result.toString() );
            trace( '---####---' );

        }

        return result;
    }

    #if thx_core 
    @:from public static macro function fromThxNil<T>(v:ExprOf<thx.Nil>):ExprOf<be.types.Default<T>> {
        var value = be.macros.Default.typeToValue( Context.getExpectedType(), v.pos );
        if (isDebug) {
            trace( '---expr---' );
            trace( value.toString() );
            trace( '---####---' );

        }
        
        return macro @:pos(v.pos) be.types.Default.fromSafeValue($e{value});
    }
    #end

    #if tink_core 
    @:from public static macro function fromTinkNil<T>(v:ExprOf<tink.core.Noise>):ExprOf<be.types.Default<T>> {
        var value = be.macros.Default.typeToValue( Context.getExpectedType(), v.pos );
        if (isDebug) {
            trace( '---expr---' );
            trace( value.toString() );
            trace( '---####---' );
            
        }
        
        return macro @:pos(v.pos) be.types.Default.fromSafeValue($e{value});
    }
    #end

    #if (eval || macro)
    private static final isDebug = Context.defined('debug') && Context.defined('default_debug');
    #end

}