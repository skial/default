package be.macros;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Metas;
import haxe.macro.Defines;
import be.types._default.Stack;
import haxe.macro.Expr.QuoteStatus;

using Std;
using tink.CoreApi;
using tink.MacroApi;
using be.macros.Default;
using haxe.macro.Context;
using haxe.macro.TypeTools;

private enum abstract SConsts(String) from String to String {
    var Default = 'Default';
    var Def = 'def';
}

private enum abstract IConsts(Int) from Int to Int {
    var DefSub = 3;
}

private enum abstract LocalDefines(Defines) {
    public var DefaultVerbose = 'default-debug';
    
    @:to public inline function asBool():Bool {
		return haxe.macro.Context.defined(this);
	}

    @:op(A == B) private static function equals(a:LocalDefines, b:Bool):Bool;
    @:op(A && B) private static function and(a:LocalDefines, b:Bool):Bool;
    @:op(A != B) private static function not(a:LocalDefines, b:Bool):Bool;
    @:op(!A) private static function negate(a:LocalDefines):Bool;
}

class Default {

    private static var counter:Int = 1;
    private static final isDebug = Debug && DefaultVerbose;

    public static function typeToValue(type:Type, pos:Position, ?stack:Null<Stack>):Expr {
        var result = switch basicType(type.reduce(), pos) {
            case macro null:
                if (isDebug) {
                    trace( 'Not basic    :   ' + type.toString() );
                }

                var explosion = explode(type, pos, stack);

                if (stack == null) {
                    explosion.snapshot(type, pos);

                } else {
                    macro @:pos(pos) $i{explosion.typeVariable(type).name};
                    
                }

            case x:
                if (isDebug) {
                    trace( 'BASIC        :   ' + type.toString() );
                    trace( 'expr         :   ' + x.toString() );
                }

                x;

        }
        
        return result;
    }

    public static function makeVariable(type:Type, pos:Position):Var {
        var ctype = type.toComplexType();
        return { name:'$Def${counter++}', type:ctype, isFinal:false, expr:macro @:pos(pos) null };
    }

    public static function explode(type:Type, pos:Position, ?params:Array<Type>, ?stack:Stack):Stack {
        var ctype = type.toComplexType();

        if (stack == null) stack = new Stack();
        if (params == null) params = [];

        var index = stack.typeIndex(type);
        if (index > -1) {
            return stack;
            
        }
        
        switch type {
            case TAbstract(_.get() => {name:Default}, p):
                stack = explode(p[0], pos, params, stack);

            case TAbstract(_.get() => abs, p):
                if (abs.impl != null) {
                    var _type =  TInst(abs.impl, p);
                    stack = explode(_type, pos, p, stack);
                    var index = stack.typeIndex( _type );
                    if (index > -1) {
                        stack.vars[index].t = type;
                        stack.vars[index].v.type = ctype;
                    }

                } else {
                    Context.fatalError( 'No implementation detected. ERROR::FIX.', pos );

                }

            case TEnum(_.get() => enm, p):
                var ctors = [];
                // Enum constructors with no arguments.
                var empties = [];
                var _variable = type.makeVariable(pos);
                var strEnmParams = enm.params.map( p -> p.t.toString() );
                
                for (name in enm.names) {
                    var field = enm.constructs.get(name);
                    switch field.type {
                        case TEnum(_, _): empties.push( field );
                        case _: ctors.push( field );
                    }
                }

                if (isDebug) {
                    trace( 'var ${_variable.name}:${_variable.type.toString()} = ${_variable.expr.toString()}' );

                }

                stack.addVariable(_variable, type);

                if (empties.length > 0) {
                    _variable.expr = macro $p{[ctype.toString(), empties[0].name]};

                } else {
                    for (ctor in ctors) switch ctor.type {
                        // Avoid constructors with any arguments that unify with itself.
                        case TFun(args, _) if (args.filter( arg -> arg.t.unify(type) ).length == 0):
                            var _args = [];
                            
                            for (arg in args) {
                                var expr:Expr = null;

                                var stringly = arg.t.toString();
                                // If the param matches a enum type parameter, attempt to convert into concrete type.
                                for (param in strEnmParams) if (/*param.t == arg.t*/param == stringly) {
                                    arg.t = arg.t.applyTypeParameters( enm.params, p );
                                }

                                for (pair in stack.vars) if (pair.t.unify(arg.t)) {
                                    var name = pair.v.name;
                                    expr = macro $i{name};
                                    break;

                                }
                            
                                if (expr == null) expr = basicType(arg.t, pos);

                                if (expr.isNullExpr()) {
                                    stack = explode(arg.t, pos, params, stack);
                                    expr = macro @:pos(pos) $i{stack.typeVariable(arg.t).name};

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
                                _variable.expr = macro $p{[enm.name, ctor.name]}($a{_args});

                            } else {
                                stack.fields.push(
                                    macro $i{_variable.name} = $p{[enm.name, ctor.name]}($a{_args})
                                );


                            }

                            break;

                        case x:
                            if (isDebug) trace( x );

                    }

                }

            case TInst(_.get() => cls, p):
                var clsVar = type.makeVariable(pos);
                var recursion:Null<Type> = null;
                var strClsParams:Array<String> = [];

                switch cls.kind {
                    case KNormal:
                        recursion = detectCircularRef(type);
                        strClsParams = cls.params.map( p -> p.t.toString() );

                    case KAbstractImpl(_.get() => abs):
                        strClsParams = abs.params.map( p -> p.t.toString() );
                        var typePath:TypePath = {
                            pack: abs.pack, name: abs.name,
                        };
                        var args = [];
                        
                        for (field in cls.statics.get()) if (field.name == '_new') {
                            field.type = field.type.reduce().applyTypeParameters( abs.params, p );
                            args = handleFunctionCall(field, pos, stack, p, abs.params, strClsParams);
                            break;
                        }

                        clsVar.expr = macro @:pos(pos) new $typePath($a{args});

                    case x:
                        if (isDebug) trace( x );

                }

                if (recursion == null) {
                    // Assume it is safe to build the class.
                    if (cls.constructor != null) {
                        var ctor = cls.constructor.get();
                        var tpath:TypePath = { pack:cls.pack, name:cls.name };
                        var args = handleFunctionCall( ctor, pos, stack, p, cls.params, strClsParams );

                        clsVar.expr = macro new $tpath($a{args});
                        if (!ctor.isPublic) clsVar.expr = macro @:privateAccess $e{clsVar.expr};
                        clsVar.expr = macro @:pos(pos) $e{clsVar.expr};

                    }

                } else {
                    if (Defines.Debug) {
                        Context.warning( 'The constructor of `${type.toString()}` will not be called. A circular dependency has been detected which is unsupported by Default.', pos );
                    }
                    // A circular ref has _potentially_ been detected.
                    // Find all Haxe initilized fields and set them.
                    for (field in cls.fields.get()) if (!field.isExtern) {
                        if (field.expr() == null) continue;

                        var stringly = field.type.toString();
                        // If the param matches a enum type parameter, attempt to convert into concrete type.
                        for (param in strClsParams) if (/*param.t == arg.t*/param == stringly) {
                            field.type = field.type.applyTypeParameters( cls.params, p );
                        }

                        var expr:Expr = null;

                        if (field.meta.has(Metas.Value)) {
                            // Extract default value used.
                            expr = field.meta.extract(Metas.Value)[0].params[0];

                        }

                        if (expr == null) try {
                            // Attempt to create a default value if one wasnt found.
                            expr = typeToValue(field.type, pos, stack);

                        } catch(e) {
                            if (isDebug) {
                                trace( e );

                            }

                        }

                        if (expr != null) {
                            // Set any Haxe initializers before returning.
                            expr = macro $p{[clsVar.name, field.name]} = $expr;
                            if (!field.isPublic) expr = macro @:privateAccess $expr;
                            stack.addExpr( expr );

                        }

                    }
    
                    clsVar.expr = macro @:pos(pos) Type.createEmptyInstance( $i{cls.name} );

                }

                stack.addVariable(clsVar, type);

            case TType(_.get() => def, _params):
                var _type = def.params.length > 0
                    ? def.type.applyTypeParameters(def.params, _params )
                    : def.type;
                var length = stack.vars.length;
                stack = explode(_type, pos, _params, stack );
                var index = stack.typeIndex(_type);
                if (index > -1) {
                    stack.vars[index].t = type;
                    stack.vars[index].v.type = type.toComplexType();

                }

            case TAnonymous(_.get() => anon):
                var _variable = type.makeVariable(pos);
                var delayedAssignments = [];
                var typeFields:Array<Field> = [];
                var objectFields:Array<ObjectField> = [];
                
                var recursion:Null<Type> = detectCircularRef(type);

                if (recursion == null) {
                    for (field in anon.fields) if (!field.meta.has(Metas.Optional)) {
                        /*var stringly = arg.t.toString();
                        // If the param matches a enum type parameter, attempt to convert into concrete type.
                        for (param in strEnmParams) if (param == stringly) {
                            field.type = field.type.applyTypeParameters( enm.params, p );
                        }*/

                        var expr:Expr = basicType(field.type, field.pos);

                        if (expr.isNullExpr()) {
                            var index = stack.typeIndex(field.type);
                            if (index > -1) {
                                expr = macro $i{stack.vars[index].v.name};
                                
                            }

                        }

                        if (expr.isNullExpr()) {
                            stack = explode( field.type, pos, params, stack );
                            expr = macro $i{stack.typeVariable(field.type).name};

                        }

                        objectFields.push({ field:field.name, expr:expr, quotes:Unquoted });

                    }

                    _variable.expr = { expr:EObjectDecl(objectFields), pos:pos };

                } else {
                    for (field in anon.fields) if (!field.meta.has(Metas.Optional)) {
                        if (field.type.unify(recursion)) {
                            var expr = macro null;
                            if (stack.vars.length > 0) {
                                var index = stack.typeIndex(field.type);
                                if (index > -1) {
                                    expr = macro $i{stack.vars[index].v.name};
                                    
                                }
                            }

                            objectFields.push({ field:field.name, expr:expr, quotes:Unquoted });
                            delayedAssignments.push( field );

                        } else {
                            var expr:Expr = basicType(field.type, field.pos);
                                
                            if (expr.isNullExpr()) {
                                var index = stack.typeIndex(field.type);
                                if (index > -1) {
                                    expr = macro $i{stack.vars[index].v.name};
                                    
                                }

                            }

                            if (expr.isNullExpr()) {
                                stack = explode( field.type, pos, params, stack );
                                expr = macro $i{stack.typeVariable(field.type).name};

                            }

                            objectFields.push({ field:field.name, expr:expr, quotes:Unquoted });

                        }

                    }

                    _variable.expr = { expr:EObjectDecl(objectFields), pos:pos };

                }

                stack.addVariable(_variable, type);

                if (delayedAssignments.length > 0) {
                    for (field in delayedAssignments) {
                        stack = explode( field.type, pos, params, stack );
                        
                        var expr:Expr = macro null;
                        var index = stack.typeIndex(field.type);
                        if (index > -1) {
                            expr = macro $i{stack.vars[index].v.name};
                            
                        }

                        stack.addExpr( macro $p{[_variable.name, field.name]} = $expr );

                    }

                }

            case TFun(args, ret):
                var _variable = type.makeVariable(pos);
                stack.vars.push( {v:_variable, t:type} );

                var _args = args.map( a -> ({
                    name:a.name, 
                    opt:a.opt, 
                    type:a.t.toComplex(),
                }:FunctionArg) );

                var _ret = basicType(ret, pos);
                
                // TODO use isNullExpr
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
                if (isDebug) {
                    trace( '---Uncaught case---');
                    trace( x );
                }

        }
        
        return stack;
    }

    private static function basicType(type:Type, pos:Position):Expr {
        var result = macro @:pos(pos) null;
        
        switch type {
            case TAbstract(_.get() => {name:Default}, _params):
                result = basicType(_params[0], pos);

            case TInst(_.get() => cls, _params) if (cls.meta.has(Metas.CoreType) || cls.meta.has(Metas.CoreApi)):
                switch cls.name {
                    case 'Array': result = macro @:pos(pos) [];
                    case 'String': result = macro @:pos(pos) be.types._default.Defaults.string;
                    case x: 
                        if (isDebug) trace( x );
                }

            case TAbstract(_.get() => abs, _params) if(abs.meta.has(Metas.CoreType) || abs.meta.has(Metas.CoreApi)):
                switch abs.name {
                    case 'Int': result = macro @:pos(pos) be.types._default.Defaults.int;
                    case 'Float': result = macro @:pos(pos) be.types._default.Defaults.float;
                    case 'Bool': result = macro @:pos(pos) be.types._default.Defaults.bool;
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

            case TAbstract(_.get() => abs, _params) if (abs.from.length > 0 && abs.from.map( f -> !basicType(f.t, pos).isNullExpr() ).length > 0):
                result = basicType(abs.type, pos);

            case x:
                //if (isDebug) trace( x );

        }

        return result;
    }

    public static inline function isNullExpr(v:Expr):Bool return switch v {
        case macro null: true;
        case _: false;
    }

    public static function handleDelayedAssignments(fields:Array<{name:String, type:Type, params:Array<TypeParameter>, pos:Position}>, params:Array<Type>, stack:Stack, id:String):Stack {
        if (isDebug) {
            trace( '---current stack---' );
            trace( stack.toString() );
        }

        for (field in fields) {
            if (isDebug) {
                trace( '---delayed assignments---' );
                trace( 'field       :   ' + field.name );
                trace( 'type        :   ' + field.type.toString() );

            }
            var expr = macro null;
            var ftype = field.type;
            if (field.params.length > 0) ftype = ftype.applyTypeParameters(field.params, params);

            for (v in stack.vars) {
                if (isDebug) {
                    trace( '---checking stack---' );
                    trace( 'var name        :   ' + v.v.name );
                    trace( 'var type        :   ' + v.v.type.toString() + ' || ' + v.t.toString() );
                }
                if (v.t.unify(ftype) || v.v.type.toType().sure().unify(ftype)) {
                    if (isDebug) {
                        trace( '---found var on stack---' );
                        trace( 'var name        :   ' + v.v.name );
                        trace( 'var type        :   ' + v.v.type.toString() + ' || ' + v.t.toString() );
                    }
                    expr = macro $i{v.v.name};
                    stack.fields.push( macro @:pos(field.pos) $p{[id, field.name]} = $i{v.v.name} );
                    break;
                }

            }
            
            // Run again in case of more complex types.
            if (expr.isNullExpr()) {
                if (isDebug) {
                    trace( '---expr null---' );
                    trace( '---explode type ' + ftype.toString() + '---' );
                }
                var explosion = explode(ftype, field.pos, params, stack);
                
                for (v in explosion.vars) if (v.t.unify(ftype) || v.v.type.toType().sure().unify(ftype)) {
                    stack.fields.push( macro $p{[id, field.name]} = $i{v.v.name} );
                    break;
                    
                }
                
                stack = /*stack + */explosion;

            }

        }

        return stack;
    }

    public static function detectCircularRef(type:Type):Null<Type> {
        var result:Null<Type> = null;
        var list:Array<Type> = [];
        var types:Array<Type> = [];
        var stypes:Array<String> = [];
        var current = type;

        while (current != null) {
            var isCore:Bool = false;
            var isFunc:Bool = false;

            switch current {
                case TInst(_.get() => cls, _):
                    if (cls.meta.has(Metas.CoreApi) || cls.meta.has(Metas.CoreType)) {
                        isCore = true;
                    }

                    if (!isCore && cls.constructor != null) {
                        list.push( cls.constructor.get().type.reduce() );

                    }

                case TAbstract(_.get() => abs, params):
                    if (abs.meta.has(Metas.CoreApi) || abs.meta.has(Metas.CoreType)) {
                        isCore = true;
                    }

                    if (!isCore) list.push( abs.type );

                case TFun(args, _):
                    isFunc = true;
                    for (a in args) list.push(a.t);

                case TType(_.get() => def, _):
                    switch def.type {
                        case TAnonymous(_.get() => anon):
                            for (field in anon.fields) {
                                list.push( field.type );

                            }

                        case x:
                            list.push( x );

                    }

                case TAnonymous(_.get() => anon):
                    for (field in anon.fields) {
                        list.push( field.type );
                    }

                case x:
                    trace( x.toString() );

            }

            if (!isCore && !isFunc) {
                var index = -1;
                if ((index = stypes.lastIndexOf(current.toString())) == -1) {
                    types.push( current );
                    stypes.push( current.toString() );
                    
                } else {
                    trace( 'loop detected.' );
                    trace( index, stypes );
                    result = types[index];
                    break;
                    
                }

            }

            current = if (list.length > 0) {
                list.shift();

            } else {
                null;

            }

        }

        return result;
    }

    public static function handleFunctionCall(field:ClassField, pos:Position, stack:Stack, concreteParams:Array<Type>, typeParams:Array<TypeParameter>, strTypeParams:Array<String>):Array<Expr> {
        var args = [];

        switch field.type.reduce() {
            case TFun(_args, _):
                for (arg in _args) {
                    if (arg.opt) break;

                    var stringly = arg.t.toString();
                    // If the param matches a class type parameter, attempt to convert into concrete type.
                    for (param in strTypeParams) if (/*param.t == arg.t*/param == stringly) {
                        arg.t = arg.t.applyTypeParameters( typeParams, concreteParams );
                    }

                    var expr:Expr = basicType( arg.t, pos );

                    if (expr.isNullExpr()) {
                        stack = explode( arg.t, pos, concreteParams, stack );
                        expr = macro $i{stack.typeVariable(arg.t).name};

                    }

                    args.push( expr );

                }

            case x:
                if (isDebug) trace( x );

        }

        return args;
    }

}