package be.types;

//import tink.json.Representation;

#if (eval || macro)
import haxe.macro.Expr;
using tink.MacroApi;
using haxe.macro.Context;
#end

using Std;
using tink.CoreApi;
/*
@:forward private abstract Safe<T>(T) {
    public #if !debug inline #end function new(v) this = v;
    @:to public #if !debug inline #end function get():T return this;
    public static #if !debug inline #end function of<T>(v:T):Safe<T> return new Safe<T>(v);
}

@:forward private abstract Unsafe<T>(T) {
    public #if !debug inline #end function new(v) this = v;
    @:to public #if !debug inline #end function get():T return this;
    public static #if !debug inline #end function of<T>(v:Null<T>, d:T):Unsafe<T> return new Unsafe<T>(v == null ? d : v);
}*/

@:forward
@:notNull
abstract Default<T>(T) from T {

    public #if !debug inline #end function new(v) this = v;

    public #if !debug inline #end function get():T return this;

    public static #if !debug inline #end function fromSafeValue<T>(v:T):Default<T> return new Default<T>(v);
    public static #if !debug inline #end function of<T>(v:Null<T>, d:T):Default<T> return new Default<T>(v == null ? d : v);

    /*@:from public static #if !debug inline #end function fromUnsafeString(v:String):Default<String> return of(v, '');
    @:from public static #if !debug inline #end function fromUnsafeInt(v:Int):Default<Int> return of(v, 0);
    @:from public static #if !debug inline #end function fromUnsafeFloat(v:Float):Default<Float> return of(v, .0);
    @:from public static #if !debug inline #end function fromUnsafeBool(v:Bool):Default<Bool> return of(v, false);
    @:from public static #if !debug inline #end function fromUnsafeArray<T>(v:Array<T>):Default<Array<T>> return of(v, []);
    @:from public static #if !debug inline #end function fromUnsafeObject(v:{}):Default<{}> return of(v, {});*/

    /*@:to public static #if !debug inline #end function asDefaultString(v:Safe<String>):Default<String> return new Default(v.get());
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
*/
    @:to public inline function toString():String return Std.string(this);
    /*#if !static
    @:to public function toTinkRep():Representation<T> return new Representation(this);
    @:from public static function fromTinkRep<T>(v:Representation<T>):Default<T> return new Default(v.get());
    #end*/

    @:from public static macro function fromNIL<T>(v:ExprOf<be.types.NIL>):ExprOf<be.types.Default<T>> {
        var value = be.macros.Default.typeToValue( Context.getExpectedType(), v.pos );
        var result = macro @:pos(v.pos) be.types.Default.fromSafeValue($value);
        
        if (isDebug) {
            trace( '---expr---' );
            //trace( value.toString() );
            /*var tde = Context.typeExpr( value );
            trace( haxe.macro.TypedExprTools.toString( tde ) );
            trace( haxe.macro.TypedExprTools.toString( tde, true ) );*/
            var buffer = new StringBuf();

            //haxe.macro.ExprTools.iter( value, printE.bind(_, buffer) );

            //trace( buffer.toString() );
            trace( result.toString() );
            trace( '---####---' );

        }

        return result;
    }

    /*#if thx_core 
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
    #end*/

    #if (eval || macro)
    private static final isDebug = Context.defined('debug') && Context.defined('default_debug');
    public static function printE(e:Expr, buf:StringBuf) {
        switch e.expr {
            case EConst(c): buf.add(c);
            case EArray(e1, e2):
                printE(e1, buf);
                printE(e2, buf);
            case EBinop(op, e1, e2):
                printE(e1, buf);
                buf.add(' ');
                buf.add(op);
                buf.add(' ');
                printE(e2, buf);
            case EField(e, f):
                printE(e, buf);
                buf.add('.$f');
            case EParenthesis(e):
                buf.add('(');
                printE(e, buf);
                buf.add(')');
            case EObjectDecl(fs):
                buf.add('{');
                for (f in fs) {
                    buf.add('${f.field}:');
                    printE(f.expr, buf);
                    buf.add('[${f.quotes}]');
                }
                buf.add('}');
            case EArrayDecl(vs):
                for (v in vs) printE(v, buf);
            case ECall(e, ps):
                printE(e, buf);
                buf.add('(');
                for (p in ps) {
                    printE(p, buf);
                    buf.add(', ');
                }
                buf.add(')');
            case ENew(tp, ps):
                buf.add( 'new ${tp.pack.concat([tp.name])}(');
                for (p in ps) printE(p, buf);
                buf.add(')');
            case EUnop(op, pf, e):
                if (!pf) buf.add(op);
                printE(e, buf);
                if (pf) buf.add(op);
            case EVars(vs):
                for (v in vs) {
                    buf.add( 'var ${v.name}:${v.type}');
                    if (v.expr != null) {
                        buf.add(' = ');
                        printE(v.expr, buf);
                    }
                    buf.add('\n');
                }
            case EFunction(k, f):
                buf.add('function ');
                buf.add(k);
                buf.add('(');
                for (a in f.args) {
                    buf.add( (a.opt ? '?' : '') + a.name + ':${a.type}');
                    if (a.value != null) {
                        buf.add(' = ');
                        printE(a.value, buf);
                    }
                    buf.add(',');
                }
                buf.add(')');
                buf.add('{\n\t\t');
                printE(f.expr, buf);
                buf.add('\n}');
            case EBlock(es):
                buf.add('{\n');
                for (e in es) {
                    buf.add('\t');
                    printE(e, buf);
                    buf.add('\n');
                }
                buf.add('\n}');
            case EFor(it, e):
                buf.add('for (');
                printE(it, buf);
                buf.add(')');
                printE(e, buf);
            case EIf(ec, ei, ee):
                buf.add('if (');
                printE(ec, buf);
                buf.add(')');
                printE(ei, buf);
                printE(ee, buf);
            case EWhile(ec, ee, normal):
                buf.add('while: ');
                printE(ec, buf);
                printE(ee, buf);
            case ESwitch(e, cs, ed):
                buf.add('switch: ');
                printE(e, buf);
                for (c in cs) {
                    buf.add('\tcase :');
                    for (v in c.values) printE(v, buf);
                    printE(c.guard, buf);
                    printE(c.expr, buf);
                }
                printE(ed, buf);
            case ETry(e, cs):
                buf.add('try: ');
                printE(e, buf);
                for (c in cs) {
                    buf.add('\tcatch: ${c.name}:${c.type} :');
                    printE(c.expr, buf);
                }
            case EReturn(e):
                buf.add('return: ');
                printE(e, buf);
            case x:
                trace( x );
        }
    }
    #end

}