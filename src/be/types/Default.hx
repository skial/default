package be.types;

import tink.json.Representation;

#if (eval || macro)
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Expr.QuoteStatus;
import be.types._default.Stack;

using tink.MacroApi;
using be.types.Default;
using haxe.macro.Context;
using haxe.macro.TypeTools;
#end

using Std;
using tink.CoreApi;

private enum abstract SConsts(String) from String to String {
    var Default = 'Default';
    var Def = 'def';
    var StructInit = ':structInit';
}

private enum abstract IConsts(Int) from Int to Int {
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
    public static #if !debug inline #end function of<T>(v:Null<T>, d:T):Unsafe<T> return new Unsafe<T>(v == null ? d : v);
}

@:forward @:notNull abstract Default<T>(T) from T {

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

    /*#if !static
    @:to public function toTinkRep():Representation<T> return new Representation(this);
    @:from public static function fromTinkRep<T>(v:Representation<T>):Default<T> return new Default(v.get());
    #end*/

    @:from public static macro function fromNIL<T>(v:ExprOf<be.types.NIL>):ExprOf<be.types.Default<T>> {
        var value = _typeToValue( Context.getExpectedType(), v.pos );

        var result = macro @:pos(v.pos) be.types.Default.fromSafeValue($e{value});
        
        if (isDebug) trace( result.toString() );

        return result;
    }

    #if thx_core 
    @:from public static macro function fromThxNil<T>(v:ExprOf<thx.Nil>):ExprOf<be.types.Default<T>> {
        var value = _typeToValue( Context.getExpectedType(), v.pos );
        if (isDebug) trace( value.toString() );
        
        return macro @:pos(v.pos) be.types.Default.fromSafeValue($e{value});
    }
    #end

    #if tink_core 
    @:from public static macro function fromTinkNil<T>(v:ExprOf<tink.core.Noise>):ExprOf<be.types.Default<T>> {
        var value = _typeToValue( Context.getExpectedType(), v.pos );
        if (isDebug) trace( value.toString() );
        
        return macro @:pos(v.pos) be.types.Default.fromSafeValue($e{value});
    }
    #end

    #if (eval || macro)
    private static var counter:Int = 1;
    private static final isDebug = Context.defined('debug') && Context.defined('default_debug');

    private static function _typeToValue(type:Type, pos:Position):Expr {
        var result = switch basicType(type.reduce(), pos) {
            case macro null:
                var explosion = explode(type, pos);
                explosion.snapshot(pos);

            case x:
                x;

        }
        
        return result;
    }

    private static function explode(type:Type, pos:Position, ?params:Array<Type>, ?stack:Stack):Stack {
        var result = new Stack();
        var id:Lazy<String> = '$Def${counter++}';
        var ttype:Lazy<Type> = () -> type;
        var ctype:Lazy<ComplexType> = ttype.map( t -> t.toComplexType() );
        var _var:Lazy<Var> = ctype.map( ct -> { name:id.get(), type:macro:Null<$ct>, isFinal:false, expr:macro null } );

        if (stack == null) stack = result;
        if (params == null) params = [];
        
        switch type {
            case TEnum(_.get() => enm, params):
                var empties = [];
                var ctors = [];
                var _variable = _var.get();
                
                for (name in enm.names) {
                    var field = enm.constructs.get(name);
                    switch field.type {
                        case TEnum(_, _): empties.push( field );
                        case _: ctors.push( field );
                    }
                }

                result.vars.push({v:_variable, t:ttype.get()});

                if (empties.length > 0) {
                    _variable.expr = '${ctype.get().toString()}.${empties[0].name}'.resolve();
                    _variable.type = ctype;

                } else {
                    for (ctor in ctors) switch ctor.type {
                        case TFun(args, ret) if (args.filter( arg -> arg.t.unify(type) ).length == 0):
                            var _args = [];
                            
                            for (arg in args) {
                                var expr = null;

                                for (pair in result.vars) if (pair.t.unify(arg.t)) {
                                    var name = pair.v.name;
                                    expr = macro $i{name};
                                    break;

                                }
                            
                                if (expr == null) expr = basicType(arg.t, pos);

                                if (expr.isNullExpr()) {
                                    var explosion = explode(arg.t, pos, params, result);
                                    result = result + explosion;
                                    expr = macro $i{explosion.vars[explosion.vars.length-1].v.name};

                                }

                                _args.push( expr );

                            }

                            var constant = true;
                            for (_arg in _args) switch _arg {
                                case {expr:EConst(CIdent(id)), pos:_}:
                                    constant = false;
                                    break;

                                case _:

                            }

                            if (constant) {
                                _variable.type = ctype;
                                _variable.expr = '${ctype.get().toString()}.${ctor.name}'.resolve().call(_args);

                            } else {
                                result.fields.push(
                                    macro $i{_variable.name} = $e{
                                        '${ctype.get().toString()}.${ctor.name}'.resolve().call(_args)
                                    }
                                );


                            }

                            break;

                        case x:
                            if (isDebug) trace( x );

                    }

                }

            case TInst(_.get() => cls, _params):
                var _variable = _var.get();
                var tpath = ttype.get().getID().asTypePath();

                if (cls.constructor != null) {
                    var ctor = cls.constructor.get();
                    var _args = switch ctor.type.reduce() {
                        case TFun(args, _):
                            [for (arg in args) basicType(arg.t, pos)];

                        case x: 
                            if (isDebug) trace( x );
                            [];

                    }

                    _variable.type = ctype;
                    _variable.expr = macro new $tpath($a{_args});
                    if (!ctor.isPublic) _variable.expr = macro @:privateAccess $e{_variable.expr};
                }

                result.vars.push({v:_variable, t:ttype});

            case TAbstract(_.get() => {name:Default}, _params):
                var explosion = explode(_params[0], pos, params);
                result = result + explosion;

            case TType(_.get() => def, _params):
                var _type = def.params.length > 0
                    ? def.type.applyTypeParameters(def.params, params.concat( _params ))
                    : def.type;
                var explosion = explode(_type, pos, params.concat( _params ) );
                if (explosion.vars[0].t.unify(ttype)) explosion.vars[0].t = ttype;
                result = result + explosion;

            case TAnonymous(_.get() => anon):
                var _variable = _var.get();
                var laterAssignments = [];
                var typeFields:Array<Field> = [];
                var objectFields:Array<ObjectField> = [];
                
                for (field in anon.fields) {
                    var fieldType = field.type;
                    if (field.params.length > 0) fieldType = fieldType.applyTypeParameters(field.params, params);
                    
                    var expr = basicType(fieldType, field.pos);
                    
                    if (expr.isNullExpr()) laterAssignments.push( field );

                    objectFields.push({ field:field.name, expr:expr, quotes:Unquoted });

                    var access = [field.isPublic ? APublic : APrivate];
                    if (field.meta.has(':final')) access.push(AFinal);
                    function varAccess(access:VarAccess, get:Bool):String {
                        return switch access {
                            case AccNo: 'null';
                            case AccNever: 'never';
                            case AccCall: get?'get':'set';
                            case _: 'default';
                        }
                    }
                    var ct = fieldType.toComplex();
                    var ft = expr.isNullExpr() && !fieldType.match(TFun(_, _)) ? (macro:Null<$ct>).toType().sure() : fieldType;
                    var kind = switch [field.kind, ft] {
                        case [FVar(read, write), ret]:
                            FProp(
                                varAccess(read, true), 
                                varAccess(write, false),
                                ret.toComplex(),
                                null
                            );

                        case [FMethod(fkind), TFun(args, ret)]:
                            access.push(ADynamic);
                            FFun({
                                args: [for (arg in args) {
                                    name: arg.name, opt: arg.opt, type: arg.t.toComplex(),
                                }],
                                ret: ret.toComplex(),
                                expr: null
                            });

                        case [a, b]:
                            if (isDebug) {
                                trace( a );
                                trace( b );

                            }
                            throw 'Unsupported Field::kind. Use `-D default_debug` with `-debug` for more information.';
                            null;

                    }

                    typeFields.push( {
                        name: field.name, pos: field.pos, doc: field.doc,
                        kind: kind, access: access, meta: field.meta.get()
                    } );

                }

                _variable.type = TAnonymous(typeFields);
                _variable.expr = { expr:EObjectDecl(objectFields), pos:pos };
                
                var pair = {v:_variable, t:ttype.get()};
                result.vars.push( pair );

                for (field in laterAssignments) {
                    var expr = macro null;
                    var fieldType = field.type;
                    if (field.params.length > 0) fieldType = fieldType.applyTypeParameters(field.params, params);
                    
                    for (v in stack.vars) if (v.t.unify(fieldType) || v.v.type.toType().sure().unify(fieldType)) {
                        expr = macro $i{v.v.name};
                        result.fields.push( macro @:pos(field.pos) $p{[id, field.name]} = $i{v.v.name} );
                        break;
                    }
                    // Run again in case of more complex types.
                    if (expr.isNullExpr()) {
                        var explosion = explode(fieldType, pos, params, result);
                        
                        for (v in explosion.vars) if (v.t.unify(fieldType) || v.v.type.toType().sure().unify(fieldType)) {
                            result.fields.push( macro $p{[id, field.name]} = $i{v.v.name} );
                            break;
                            
                        }
                        
                        result = result + explosion;

                    }

                }
                
                
                var tt = pair.v.type.toType().sure();
                if (!pair.t.unify(tt)) pair.t = tt;


            case TFun(args, ret):
                var _variable = _var.get();
                _variable.type = ctype;
                result.vars.push( {v:_variable, t:type} );
                var _args = args.map( a -> ({
                    name:a.name, 
                    opt:a.opt, 
                    type:a.t.toComplex(),
                }:FunctionArg) );

                var _ret = basicType(ret, pos);
                
                switch _ret {
                    case macro null:
                        for (pair in stack.vars) {
                            if (pair.t.unify(ret) || pair.v.type.toType().sure().unify(ret)) {
                                _ret = macro cast $i{pair.v.name};
                                break;

                            }

                        }

                    case _:


                }

                _variable.expr = {
                    expr:EFunction(null, {
                        args: _args,
                        ret: ret.toComplex(),
                        expr: macro return $_ret,
                        params: [],
                    }), 
                    pos:pos 
                }

            case x:
                if (isDebug) trace( x );

        }
        
        return result;
    }

    private static function basicType(type:Type, pos:Position):Expr {
        var result = macro @:pos(pos) null;
        
        switch type {
            case TAbstract(_.get() => {name:Default}, _params):
                result = basicType(_params[0], pos);

            case TInst(_.get() => cls, _params) if (cls.meta.has(':coreType') || cls.meta.has(':coreApi')):
                switch cls.name {
                    case 'Array': result = macro @:pos(pos) [];
                    case 'String': result = macro @:pos(pos) be.types.Defaults.string;
                    case x: 
                        if (isDebug) trace( x );
                }

            case TAbstract(_.get() => abs, _params) if(abs.meta.has(':coreType') || abs.meta.has(':coreApi')):
                switch abs.name {
                    case 'Int': result = macro @:pos(pos) be.types.Defaults.int;
                    case 'Float': result = macro @:pos(pos) be.types.Defaults.float;
                    case 'Bool': result = macro @:pos(pos) be.types.Defaults.bool;
                    case 'Null': result = basicType(_params[0], pos);
                    case x: 
                        if (isDebug) trace( x );
                    
                }

            case TType(_.get() => def, _params) if (def.name == 'Null'):
                result = basicType(_params[0], pos);

            case TType(_.get() => def, _params):
                result = basicType(def.type, pos);

            case TDynamic(n) if (n != null):
                result = macro @:pos(pos) {};

            case TAbstract(_.get() => abs, _params):
                result = basicType(abs.type, pos);

            case x:
                if (isDebug) trace( x );

        }

        return result;
    }

    public static inline function isNullExpr(v:Expr):Bool return switch v {
        case macro null: true;
        case _: false;
    }

    public static inline function unwrap(type:Type):Type {
        return switch type {
            case TAbstract(_.get() => {name:Default}, p): p[0];
            case _: type;
        }
    }
    public static inline function isDefault(type:Type):Bool return switch type {
        case TAbstract(_.get() => {name:Default}, _): true;
        case _: false;
    }
    #end

}