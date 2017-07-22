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
        counter = 0;
        var v = typeToValue( Context.getExpectedType() );
        var ctype = Context.getExpectedType().toComplex();
        #if debug
        trace( v.toString() );
        #end
        return macro new be.types.Default<$ctype>($v);
    }

    #if (macro||eval)
    private static var counter = 0;
    private static function typeToValue(type:Type, ?toplevel:Map<String, Var>):Expr {
        var result = null;
        var ctype = type.toComplex();
        var stype = ctype.toString();

        var first = toplevel == null;
        if (first) toplevel = new Map();

        if (!toplevel.exists(stype)) switch type {
            case TAbstract(_.get()=>abs, p) if (abs.name == 'Default'):
                result = typeToValue(p[0], toplevel);
            
            case TInst(_.get()=>cls, _):
                switch cls.name {
                    case 'Array': result = macro [];
                    case 'String': result = macro '';
                    case x: 
                        if (cls.constructor != null) {
                            var tpath = stype.asTypePath();

                            switch cls.constructor.get().type {
                                case TFun(arg, _):
                                    if (cls.meta.has(':structInit')) {
                                        var call = [];
                                        for (a in arg) call.push( {field:a.name, expr:typeToValue(a.t, toplevel)} );
                                        result = {expr:EObjectDecl(call), pos:Context.currentPos()};

                                    } else {
                                        var call = [];
                                        for (a in arg) {
                                            var e = typeToValue(a.t, toplevel);
                                            call.push( e );
                                        }
                                        result = macro new $tpath($a{call});

                                    }
                                    
                                    var id = 'def${counter++}';
                                    toplevel.set(stype, {name:id, type:null, expr:result});
                                    result = macro $i{id};

                                case _:

                            }

                        } else {
                            trace( x );

                        }

                }

            case TAbstract(_.get()=>abs, _):
                switch abs.name {
                    case 'Int': result = macro 0;
                    case 'Float': result = macro .0;
                    case x: trace(x);

                }

            case TAnonymous(_.get()=>anon):
                var fields = [];

                for (field in anon.fields) {
                    var ct = field.type.toComplex();
                    var id = ct.toString();
                    var n = field.name;
                    var v = toplevel.exists(id) ? toplevel.get(id) : null;
                    var e = v == null ? typeToValue(field.type, toplevel) : v.expr;
                    
                    switch e {
                        case {expr:EConst(CIdent(id))}:
                            toplevel.set(field.name + counter + stype, {name:'def${counter++}', type:field.type.toComplex(), expr:macro $i{'def${counter}'}.$n = $i{'def$counter'}});

                        case x:
                    }
                    
                    fields.push( {field:field.name, expr: macro ($e:$ct)} );

                }
                result = macro $e{{expr:EObjectDecl(fields), pos:Context.currentPos()}};

            case TType(_.get()=>td, p):
                if (td.name == 'Null') {
                    result = typeToValue( p[0], toplevel );

                } else {
                    var id = 'def${counter++}';
                    toplevel.set(stype, {name:id, type:null, expr:macro null});
                    result = typeToValue( td.type, toplevel );
                    toplevel.set('stype${counter}', {name:id = 'def${counter++}', type:null, expr:result});
                    result = macro $i{id};  

                }              

            case x: trace(x);
        } else {
            var v = toplevel.get(stype);
            result = macro $i{v.name};

        }

        if (first) {
            var exprs = [];
            
            for (key in toplevel.keys()) {
                var v = toplevel.get(key);
                if (v.expr == null) v.expr = macro null;
                exprs.push( {expr:EVars([v]), pos:Context.currentPos()} );


            }

            if (exprs.length > 0) {
                exprs.push(macro $result);
                result = macro @:mergeBlock $b{exprs};

            }

        }
        
        return result;
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