package be.types;

#if macro
import haxe.macro.Type;
import haxe.macro.Expr;

using tink.MacroApi;
using haxe.macro.Context;
#end

using Std;
using tink.CoreApi;

@:enum private abstract SConsts(String) from String to String {
    var Default = 'Default';
    var Def = 'def';
    var StructInit = ':structInit';
}

@:enum private abstract IConsts(Int) from Int to Int {
    var DefSub = 3;
}

@:forward private abstract Safe<T>(T) {
    public #if !debug inline #end function new(v) this = v;
    @:to public #if !debug inline #end function get():T return this;
    public static #if !debug inline #end function of<T>(v:T):Safe<T> return new Safe<T>(v);
}

@:forward private abstract Unsafe<T>(T) {
    public #if !debug inline #end function new(v) this = v;
    @:to public #if !debug inline #end function get():T return this;
    public static #if !debug inline #end function of<T>(v:T, d:T):Unsafe<T> return new Unsafe<T>(v == null ? d : v);
}

// @see https://github.com/HaxeFoundation/haxe/issues/4756
@:forward abstract Default<T>(T) {

    public #if !debug inline #end function new(v) this = v;

    public #if !debug inline #end function get():T return this;

    public static #if !debug inline #end function fromSafeValue<T>(v:T):Default<Safe<T>> return new Default<Safe<T>>(new Safe<T>(v));
    public static #if !debug inline #end function of<T>(v:T, d:T):Default<T> return new Default<T>(v == null ? d : v);

    @:from public static #if !debug inline #end function fromUnsafeString(v:String):Default<String> return of(v, '');
    @:from public static #if !debug inline #end function fromUnsafeInt(v:Int):Default<Int> return of(v, 0);
    @:from public static #if !debug inline #end function fromUnsafeFloat(v:Float):Default<Float> return of(v, .0);
    @:from public static #if !debug inline #end function fromUnsafeBool(v:Bool):Default<Bool> return of(v, false);
    @:from public static #if !debug inline #end function fromUnsafeArray<T>(v:Array<T>):Default<Array<T>> return of(v, []);
    @:from public static #if !debug inline #end function fromUnsafeObject(v:{}):Default<{}> return of(v, {});

    @:from public static macro function fromStruct(v:ExprOf<{}>):Expr {
        #if debug
        trace( v.toString(), v.typeof() );
        #end
        return macro be.types.Default.of( $v, $e{typeToValue(v.typeof())} );
    }

    @:to public static #if !debug inline #end function asDefaultString(v:Safe<String>):Default<String> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultInt(v:Safe<Int>):Default<Int> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultFloat(v:Safe<Float>):Default<Float> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultBool(v:Safe<Bool>):Default<Bool> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultArray<T>(v:Safe<Array<T>>):Default<Array<T>> return new Default(v.get());
    @:to public static #if !debug inline #end function asDefaultStringlyArray<T>(v:Safe<Array<T>>):Default<String> return new Default('' + v);
    @:to public static #if !debug inline #end function asDefaultObject(v:Safe<{}>):Default<{}> return new Default(v.get());

    @:to public static #if !debug inline #end function asString(v:String):String return (v == null ? '' : v);
    @:to public static #if !debug inline #end function asInt(v:Int):Int return (v == null ? 0 : v);
    @:to public static #if !debug inline #end function asFloat(v:Float):Float return (v == null ? .0 : v);
    @:to public static #if !debug inline #end function asBool(v:Bool):Bool return (v == null ? false : v);
    @:to public static #if !debug inline #end function asArray<T>(v:Array<T>):Array<T> return (v == null ? [] : v);
    @:to public static #if !debug inline #end function asStringlyArray<T>(v:Array<T>):String return '' + (v == null ? [] : v);
    @:to public static #if !debug inline #end function asObject(v:{}):{} return (v == null ? {} : v);

    @:from public static macro function fromNIL<T>(v:ExprOf<be.types.NIL>):ExprOf<be.types.Default<T>> {
        counter = 0;
        var v = typeToValue( Context.getExpectedType() );
        var ctype = Context.getExpectedType().toComplex();
        #if debug
        trace( v.toString() );
        #end
        return macro be.types.Default.fromSafeValue($v);
    }

    #if thx_core 
    @:from public static macro function fromThxNil<T>(v:ExprOf<thx.Nil>):ExprOf<be.types.Default<T>> {
        counter = 0;
        var v = typeToValue( Context.getExpectedType() );
        var ctype = Context.getExpectedType().toComplex();
        #if debug
        trace( v.toString() );
        #end
        return macro be.types.Default.fromSafeValue($v);
    }
    #end

    #if tink_core 
    @:from public static macro function fromTinkNil<T>(v:ExprOf<tink.core.Noise>):ExprOf<be.types.Default<T>> {
        counter = 0;
        var v = typeToValue( Context.getExpectedType() );
        var ctype = Context.getExpectedType().toComplex();
        #if debug
        trace( v.toString() );
        #end
        return macro be.types.Default.fromSafeValue($v);
    }
    #end

    #if (macro || eval)
    private static var counter = 0;
    private static function typeToValue(type:Type, ?toplevel:Map<String, Var>):Expr {
        var result = null;
        var ctype = type.toComplex();
        var stype = ctype.toString();

        var first = toplevel == null;
        if (first) toplevel = new Map();

        if (!toplevel.exists(stype)) {
            
            switch type {
                case TAbstract(_.get() => abs, p) if (abs.name == Default):
                    result = typeToValue(p[0], toplevel);
                
                case TEnum(_.get() => enm, p) if (enm.names.length > 0):
                    var r = null;
                    
                    for (name in enm.names) switch enm.constructs.get(name).type {
                        case TFun(args, ret) if (args.length > 0 && args.filter(a -> a.t.toComplex().toString() == stype).length == 0):
                            r = '$stype.$name'.resolve();
                            
                            var cargs = [for (arg in args) {
                                var ct = arg.t.toComplex();
                                var st = ct.toString();

                                var def = typeToValue(arg.t, toplevel);
                                avoidRecursion(ct, def, arg.name, toplevel);

                            }];

                            r = r.call(cargs);
                            break;

                        case TEnum(_, _):
                            r = '$stype.$name'.resolve();
                            break;

                        case x:
                            //trace(x);

                    }
                    if (r == null) Context.error('Could not construct ${stype}.', enm.pos);
                    result = r;

                case TInst(_.get() => cls, _):
                    switch cls.name {
                        case 'Array': result = macro [];
                        case 'String': result = macro '';
                        case x: 
                            if (cls.constructor != null) {
                                var tpath = stype.asTypePath();

                                switch cls.constructor.get().type.reduce() {
                                    case TFun(arg, _):
                                        if (cls.meta.has(StructInit)) {
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
                                        
                                        var id = '$Def${counter++}';
                                        toplevel.set(stype, {name:id, type:null, expr:result});
                                        result = macro cast $i{id};

                                    case x:
                                        result = typeToValue(x);
                                }

                            } else {
                                trace( x );

                            }

                    }

                case TAbstract(_.get() => abs, p):
                    switch abs.name {
                        case 'Int': result = macro 0;
                        case 'Float': result = macro .0;
                        case 'Bool': result = macro false;
                        case 'Null': result = typeToValue(p[0]);
                        case x: trace(x);

                    }

                case TAnonymous(_.get() => anon):
                    var fields = [];

                    for (field in anon.fields) {
                        
                        var ct = field.type.toComplex();
                        var def = typeToValue(field.type, toplevel);
                        var e = avoidRecursion(ct, def, field.name, toplevel);
                        
                        fields.push( {field:field.name, expr: macro ($e:$ct)} );

                    }
                    
                    result = macro @:tanonymous $e{{expr:EObjectDecl(fields), pos:Context.currentPos()}};

                case TType(_.get() => td, p):
                    if (td.name == 'Null') {
                        result = typeToValue( p[0], toplevel );

                    } else {
                        result = cache(td.type, stype, toplevel);

                    }
                case TLazy(l):
                    return typeToValue( l() );

                case x: trace(x);
            }

        } else {
            var v = toplevel.get(stype);
            result = macro $i{v.name};

        }

        if (first) {
            var vars = [];
            var exprs = [];
            
            for (key in toplevel.keys()) {
                var v = toplevel.get(key);
                if (v.expr == null) v.expr = macro null;
                vars.push(v);

            }

            vars.sort( (a, b)->a.name.substring(DefSub).parseInt() > b.name.substring(DefSub).parseInt() ? 1 : 0 );
            exprs = vars.map(v->{expr:EVars([v]), pos:Context.currentPos()});

            if (exprs.length > 0) {
                exprs.push(macro $result);
                result = macro @:mergeBlock $b{exprs};

            }

        }
        
        return result;
    }

    private static function cache(type:Type, stype:String, toplevel:Map<String, Var>):Expr {
        var id = '$Def${counter++}';
        toplevel.set(stype, {name:id, type:null, expr:macro null});
        var result = typeToValue( type, toplevel );
        toplevel.set('$stype${counter}', {name:id = '$Def${counter++}', type:null, expr:macro @:DefaultCache $result});
        return macro $i{id};
    }

    private static function avoidRecursion(ctype:ComplexType, defExpr:Expr, access:String, toplevel:Map<String, Var>):Expr {
        var result = defExpr;
        var name = ctype.toString();
        var variable = toplevel.exists(name) ? toplevel.get(name) : null;
        var variableName = '$Def${counter-1}';

        if (variable != null) {
            result = variable.expr;
            variableName = variable.name;

        }

        switch result {
            case {expr:EConst(CIdent(value))} if (value == 'null'):
                variableName = '$Def${variableName.substring(DefSub).parseInt() + 1}';
                toplevel.set(
                    name + counter + Date.now().toString(), 
                    {name:'$Def${counter+1}', type:ctype, expr:macro @:tanonfield $i{'$Def$counter'}.$access = $i{variableName}}
                );

            case x:

        }

        return result;
    }
    #end

}