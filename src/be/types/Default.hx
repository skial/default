package be.types;

#if macro
import haxe.macro.Type;
import haxe.macro.Expr;

using tink.MacroApi;
using haxe.macro.Context;
#end

using tink.CoreApi;

// @see https://github.com/HaxeFoundation/haxe/issues/4756
@:forward abstract Default<T>(T) from T {

    public #if !debug inline #end function new(v) this = v;

    public #if !debug inline #end function get():T return this;

    @:to public static #if !debug inline #end function asObject(v:Default<{}>):{} return v == null ? {} : v.get();
    @:to public static #if !debug inline #end function asStringyArray<T>(v:Default<Array<T>>):String return v == null ? '[]' : '' + v.get();
    @:to public static #if !debug inline #end function asString<T:String>(v:Default<T>):String return v == null ? '' : v.get();
    @:to public #if !debug inline #end function asFloat():Float return this == null ? .0 : (cast this:Float);
    @:to public #if !debug inline #end function asInt():Int return this == null ? 0 : (cast this:Int);
    @:to public #if !debug inline #end function asArray<A>():Array<A> return this == null ? [] : (cast this:Array<A>);

    @:from public static macro function fromNILL<T>(v:ExprOf<NIL>):ExprOf<be.types.Default<T>> {
        var v = typeToValue( Context.getExpectedType() );
        var ctype = Context.getExpectedType().toComplex();
        #if debug
        trace( v.toString() );
        #end
        return macro new be.types.Default<$ctype>($v);
    }

    #if (macro||eval)
    private static function typeToValue(type:Type):Expr {
        switch type {
            case TAbstract(_.get()=>abs, p) if (abs.name == 'Default'):
                return typeToValue(p[0]);
            
            case TInst(_.get()=>cls, _):
                switch cls.name {
                    case 'Array': return macro [];
                    case 'String': return macro '';
                    case x: 
                        if (cls.constructor != null) {
                            var tpath = type.toComplex().toString().asTypePath();

                            switch cls.constructor.get().type {
                                case TFun(arg, _):
                                    if (cls.meta.has(':structInit')) {
                                        var call = [];
                                        for (a in arg) call.push( {field:a.name, expr:typeToValue(a.t)} );
                                        return {expr:EObjectDecl(call), pos:Context.currentPos()};

                                    } else {
                                        var call = [];
                                        for (a in arg) call.push( typeToValue(a.t) );
                                        return macro new $tpath($a{call});

                                    }

                                case _:

                            }

                        } else {
                            trace( x );

                        }

                }

            case TAbstract(_.get()=>abs, _):
                switch abs.name {
                    case 'Int': return macro 0;
                    case 'Float': return macro .0;
                    case x: trace(x);

                }

            case TAnonymous(_.get()=>anon):
                var fields = [];
                for (field in anon.fields) {
                    //trace(field);
                    fields.push( {field:field.name, expr: typeToValue(field.type)} );

                }
                return macro cast $e{{expr:EObjectDecl(fields), pos:Context.currentPos()}};

            case TType(_.get()=>td, p):
                return if (td.name == 'Null') {
                    typeToValue( p[0] );
                } else {
                    typeToValue( td.type );

                }

            case x: trace(x);
        }
        return macro null;
    }

    #end

    /*#if macro
    @:from public static inline function fromComplex(v:ComplexType):Expr {
        return switch v.toType() {
            case Success(t): fromType(t);
            case _: macro {};
        }
    }

    @:from public static inline function fromType(v:Type):Expr {
        var r = switch v.getID() {
            case 'String': macro '';
            case 'Array': macro [];
            case _: 
                trace( v );
                macro {};
        }
        
        return r;
    }
    #end*/

}