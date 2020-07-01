package be.macros;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Metas;
import haxe.macro.Defines;
import be.types.defaulting.Stack;
import be.types.defaulting.Errors;
import be.types.defaulting.Warnings;
import haxe.macro.Expr.QuoteStatus;

using Std;
using StringTools;
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

    private static var counter:Int = 0;
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
                    switch explosion.exprDef(type) {
                        case EVars(vars):
                            macro @:pos(pos) $i{vars[0].name};

                        case EFunction(FNamed(name), _):
                            macro @:pos(pos) $i{name};

                        case x:
                            Context.fatalError( Errors.UnexpectedExpression, pos );

                    }
                    
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
        var ctype:Null<ComplexType> = switch type {
            case TAnonymous(_): 
                null;

            case TFun(args, _):
                // Ignore the type parameter.
                if (args.filter( a -> a.t.match( TInst(_.get() => {kind:KTypeParameter(_)}, _) ) ).length > 0) {
                    null;

                } else {
                    type.toComplexType();

                }

            case _:
                type.toComplexType();

        }
        
        return { name:'$Def${counter++}', type:ctype, isFinal:false, expr:macro null };
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

            case TAbstract(_.get() => abs, p) if (!abs.meta.has(Metas.CoreApi) || abs.meta.has(Metas.CoreType)):
                var recursion:Null<Type> = null;

                // Attempt to use the implementations static `_new`.
                if (abs.impl != null) {
                    var inst = TInst(abs.impl, p);
                    recursion = detectCircularRef(inst, [type]);

                    if (recursion == null) {
                        stack = explode( inst, pos, params, stack );
                        var index = stack.typeIndex( inst );
                        var exprdef = stack.exprs[index];

                        if (exprdef != null) {
                            stack.exprTypes[index] = type;
                            switch exprdef {
                                case EVars(vars):
                                    vars[0].type = ctype;
                                    
                                    if (!vars[0].expr.isNullExpr()) {
                                        if (isDebug) trace( vars[0] );
                                        return stack;

                                    } else {
                                        stack.exprs.pop();

                                    }

                                case _:

                            }

                        }

                    }

                }

                // Attempt to create a type from a compatible `from $type` expression.
                if (abs.from.length > 0) {
                    for (field in abs.from) {
                        /**
                            Run `detectCircularRef` for each `from` type, 
                            preloaded with original abs `type`.
                        **/
                        recursion = detectCircularRef(field.t, [type]);

                        if (recursion == null) {
                            var expr:Expr = basicType( field.t, pos );

                            if (expr.isNullExpr()) {
                                stack = explode( field.t, pos, params, stack );
                                
                                var exprdef = stack.exprDef( field.t );
                                if (exprdef != null) {
                                    switch exprdef {
                                        case EVars(vars):
                                            vars[0].type = ctype;

                                        case _:

                                    }

                                    return stack;
                                }

                            } else {
                                var absVar = type.makeVariable(pos);
                                absVar.expr = expr;
                                stack.addVariable(absVar, type);

                                return stack;
                            }

                        }

                    }

                }

                // Attempt to build its raw type and casting to type.
                recursion = detectCircularRef(abs.type, [type]);
                if (recursion == null) {
                    stack = explode( abs.type, pos, params, stack );

                    var index = stack.typeIndex( abs.type );
                    var exprdef = stack.exprs[index];
                    if (exprdef != null) stack.exprTypes[index] = type;
                    switch exprdef {
                        case EVars(vars):
                            if (!vars[0].expr.isNullExpr()) {
                                vars[0].type = ctype;
                                vars[0].expr = macro cast $e{vars[0].expr};
                                return stack;

                            }

                        case _:
                            stack.exprs.pop();

                    }

                }
                
                
                if (recursion != null) {
                    Context.fatalError( Errors.CircularDependency.replace('::a::', type.toString()).replace('::b::', recursion.toString()), pos );

                } else {
                    Context.fatalError( Errors.NoExpression, pos );

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

                stack.addVariable(_variable, type);

                if (empties.length > 0) {
                    _variable.expr = macro $p{[enm.name, empties[0].name]};

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

                                /*for (pair in stack.vars) if (pair.t.unify(arg.t)) {
                                    var name = pair.v.name;
                                    expr = macro $i{name};
                                    break;

                                }*/
                                var exprdef = stack.exprDef(arg.t);
                                if (exprdef != null) expr = {expr:exprdef, pos:pos};
                            
                                if (expr == null) expr = basicType(arg.t, pos);

                                if (expr.isNullExpr()) {
                                    stack = explode(arg.t, pos, params, stack);
                                    //expr = macro @:pos(pos) $i{stack.typeVariable(arg.t).name};
                                    //expr = {expr:stack.exprDef(arg.t), pos:pos};
                                    switch stack.exprDef(arg.t) {
                                        case EVars(vars):
                                            expr = macro $i{vars[0].name};

                                        case EFunction(FNamed(name, false), _):
                                            expr = macro $i{name};

                                        case _:

                                    }

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
                                /*stack.fields.push(
                                    macro $i{_variable.name} = $p{[enm.name, ctor.name]}($a{_args})
                                );*/
                                stack.addExpr( macro $i{_variable.name} = $p{[enm.name, ctor.name]}($a{_args}) );


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
                var creator:Null<ClassField> = null;
                var makeExpr:Null<Array<Expr>->Expr> = null;

                switch cls.kind {
                    case KNormal:
                        recursion = detectCircularRef(type);
                        strClsParams = cls.params.map( p -> p.t.toString() );

                    case KAbstractImpl(_.get() => abs):
                        strClsParams = abs.params.map( p -> p.t.toString() );
                        var typePath:TypePath = {
                            pack: abs.pack, name: abs.name,
                        };
                        
                        for (field in cls.statics.get()) if (field.name == '_new' && field.isPublic) {
                            field.type = field.type.reduce().applyTypeParameters( abs.params, p );
                            creator = field;
                            break;
                        }

                        makeExpr = args -> macro @:pos(pos) new $typePath($a{args});

                    case x:
                        if (isDebug) trace( x );

                }

                if (recursion == null) {
                    // Assume it is safe to build the class.
                    if (cls.constructor != null) {
                        creator = cls.constructor.get();
                        creator.type = creator.type.applyTypeParameters( cls.params, p );
                        var tpath:TypePath = { pack:cls.pack, name:cls.name };
                        makeExpr = args -> {
                            var e = macro @:pos(pos) new $tpath($a{args});
                            if (!creator.isPublic) e = macro @:privateAccess $e;
                            e;
                        }

                    }

                    if (creator != null && makeExpr != null) {
                        var args = handleFunctionCall( creator, pos, stack, p, cls.params, strClsParams );
                        clsVar.expr = makeExpr( args );

                    }

                } else {
                    if (Defines.Debug) {
                        Context.warning( Warnings.MakeEmptyClass.replace('::t::', type.toString()), pos );

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

            case TType(_.get() => def, p):
                var _type = def.params.length > 0
                    ? def.type.applyTypeParameters(def.params, p )
                    : def.type;

                var expr = basicType(_type, pos);

                if (expr.isNullExpr()) {
                    stack = explode(_type, pos, p, stack );
                    var index = stack.typeIndex(_type);
                    switch stack.exprs[index] {
                        case EVars(vars):
                            vars[0].type = ctype;
                            stack.exprTypes[index] = type;

                        case null, _:
                            if (isDebug) trace( stack.toString() );
                            Context.fatalError( Errors.MissingSubType.replace('::t::', _type.toString()), pos );

                    }

                } else {
                    var defVar = type.makeVariable(pos);
                    defVar.expr = expr;
                    stack.addVariable(defVar, type);

                }

            case TAnonymous(_.get() => anon):
                var _variable = { name:'$Def${counter++}', type:null, isFinal:false, expr:macro null };
                var delayedAssignments = [];
                var typeFields:Array<Field> = [];
                var objectFields:Array<ObjectField> = [];
                var recursion:Null<Type> = detectCircularRef(type);
                
                for (field in anon.fields) if (!field.isExtern && !field.meta.has(Metas.Optional)) {
                    if (field.params.length == params.length) {
                        field.type = field.type.applyTypeParameters( field.params, params );

                    }

                    // Attempt to get a basic type expression.
                    var expr:Expr = basicType(field.type, field.pos);

                    if (expr.isNullExpr()) {
                        // Its not a basic type, see if it exists on the stack.
                        var exprdef = stack.exprDef( field.type );
                        switch exprdef {
                            case EVars(vars): expr = macro $i{vars[0].name};
                            case EFunction(FNamed(name, false), _): expr = macro $i{name};
                            case x: if (isDebug) trace( x );
                        }

                    }

                    var delayed = false;
                    /**
                        Check the field type against possible recursion and
                        delay assignment if it does.
                    **/
                    if (recursion != null && field.type.unify(recursion)) {
                        delayedAssignments.push( field );
                        delayed = true;
                    }

                    if (!delayed && expr.isNullExpr()) {
                        // It doesnt exist on the stack. Attempt to add it.
                        stack = explode( field.type, field.pos, params, stack );
                        var index = stack.typeIndex( field.type );
                        var exprdef = stack.exprs[index];

                        switch exprdef {
                            case EVars(vars):
                                expr = macro $i{vars[0].name};

                            case EFunction(FNamed(name, false), method):
                                var paramNames = method.params.map( p -> p.name );
                                switch field.type {
                                    // The returned expr is meant to be used as a closure.
                                    case TFun(args, ret) if (method.args.length > args.length):
                                        var delay:Bool = false;
                                        if (recursion != null) for (arg in method.args) {
                                            /**
                                                If the arg type is a type parameter or unifies with
                                                `recursion`, delay building the expression.
                                            **/
                                            switch arg.type {
                                                case TPath({name: n}) if (paramNames.indexOf( n ) > -1):
                                                    delay = true;
                                                    break;

                                                case _:
                                                    if (haxe.macro.ComplexTypeTools.toType( arg.type ).unify( recursion )) {
                                                        delay = true;
                                                        break;

                                                    }

                                            }

                                        }

                                        if (!delay) {
                                            /**
                                                The type used to index it on the stack is wrong
                                                wipe it so it doesnt get unified by mistake.
                                            **/
                                            stack.exprTypes[index] = null;
                                            // Create bindable args
                                            var bindArgs = [];
                                            for (i in 0...method.args.length) if (i < args.length) {
                                                bindArgs.push( macro _ );
    
                                            } else {
                                                // Check if the type exists on the stack.
                                                var outcome = method.args[i].type.toType();
                                                switch outcome {
                                                    case Success(t):
                                                        var _index = stack.typeIndex(t);
                                                        switch stack.exprs[_index] {
                                                            case EVars(vars):
                                                                bindArgs.push( macro $i{vars[0].name} );
    
                                                            case EFunction(FNamed(name, false), _):
                                                                bindArgs.push( macro $i{name} );
    
                                                            case null, _:
                                                                Context.fatalError( Errors.UnexpectedExpression, pos );
    
                                                        }
    
                                                    case Failure(e):
                                                        Context.fatalError(e.toString(), pos);
    
                                                }
                                            }
    
                                            expr = macro $i{name}.bind($a{bindArgs});

                                        } else {
                                            // A recursion was detected. Postpone setting the field.
                                            delayedAssignments.push( field );
                                            switch field.kind {
                                                case FMethod(fk) if (!fk.match(MethDynamic)):
                                                    Context.fatalError( Errors.MethodNotDynamic, field.pos );

                                                case _:

                                            }
                                        }

                                    case _:
                                        expr = macro $i{name};

                                }

                            case x:
                                if (isDebug) trace( x );

                        }

                    }

                    var access = [field.isPublic ? APublic : APrivate];
                    if (field.meta.has(Metas.Final)) access.push( AFinal );
                    var kind = switch [field.kind, field.type] {
                        case [FVar(read, write), ret]:
                            FProp(
                                varAccess(read, true), 
                                varAccess(write, false),
                                ret.toComplexType(),
                                null
                            );

                        case [FMethod(fkind), TFun(args, ret)]:
                            if (fkind.match(MethDynamic)) access.push(ADynamic);
                            FFun({
                                args: [for (arg in args) {
                                    name: arg.name, opt: arg.opt, type: arg.t.toComplexType(),
                                }],
                                params: field.params.map( p -> { name:p.name, constraints:null, meta:null, params:null } ),
                                ret: ret.toComplexType(),
                                expr: null
                            });

                        case [a, b]:
                            if (isDebug) {
                                trace( a );
                                trace( b );

                            }
                            Context.fatalError( Errors.UnexpectedExpression, pos );
                            null;

                    }

                    typeFields.push( {
                        name: field.name, pos: field.pos, doc: field.doc,
                        kind: kind, access: access, meta: field.meta.get()
                    } );
                    objectFields.push( {
                        field: field.name, expr: expr, quotes: Unquoted
                    } );

                }

                _variable.type = TAnonymous(typeFields);
                _variable.expr = { expr: EObjectDecl(objectFields), pos: pos };
                stack.addVariable(_variable, type);

                for (field in delayedAssignments) if (!field.isExtern && !field.meta.has(Metas.Optional)) {
                    // Attempt to get a basic type expression.
                    var expr:Expr = basicType(field.type, field.pos);

                    if (expr.isNullExpr()) {
                        // It doesnt exist on the stack. Attempt to add it.
                        stack = explode( field.type, field.pos, params, stack );
                        var index = stack.typeIndex( field.type );
                        var exprdef = stack.exprs[index];

                        switch exprdef {
                            case EVars(vars):
                                expr = macro $i{vars[0].name};

                            case EFunction(FNamed(name, false), method):
                                switch field.type {
                                    // The returned expr is meant to be used as a closure
                                    case TFun(args, ret) if (method.args.length > args.length):
                                        /**
                                            The type used to index it on the stack is wrong
                                            wipe it so it doesnt get unified by mistake.
                                        **/
                                        stack.exprTypes[index] = null;
                                        // Create bindable args
                                        var bindArgs = [];
                                        for (i in 0...method.args.length) if (i < args.length) {
                                            bindArgs.push( macro _ );

                                        } else {
                                            // Check if the type exists on the stack.
                                            var outcome = method.args[i].type.toType();
                                            switch outcome {
                                                case Success(t):
                                                    var _index = stack.typeIndex(t);
                                                    switch stack.exprs[_index] {
                                                        case EVars(vars):
                                                            bindArgs.push( macro $i{vars[0].name} );

                                                        case EFunction(FNamed(name, false), _):
                                                            bindArgs.push( macro $i{name} );

                                                        case _:
                                                            Context.fatalError( Errors.UnexpectedExpression, pos );

                                                    }

                                                case Failure(e):
                                                    Context.fatalError(e.toString(), pos);

                                            }

                                        }

                                        expr = macro $i{name}.bind($a{bindArgs});

                                    case _:
                                        expr = macro $i{name};

                                }

                            case _:

                        }

                    }

                    // @see https://github.com/HaxeFoundation/haxe/issues/9669
                    if (Context.defined('cs') || Context.defined('java')) {
                        var localVar = { name:'$Def${counter++}', type:null, isFinal:false, expr:expr };
                        expr = macro $i{localVar.name};
                        stack.addVariable(localVar, null);

                    }

                    stack.addExpr( macro $p{[_variable.name, field.name]} = $expr );

                }

            case TFun(args, ret):
                var cret = ret.toComplexType();
                var _variable = type.makeVariable(pos);
                var func:Function = { args: [], ret: null, expr: null, params: [] };
                var count = 0;

                for (arg in args) {
                    var _name = arg.name;
                    
                    // TODO check for clashing names.
                    if (_name == '') {
                        _name = genAscii(count++);
                    }

                    switch arg.t {
                        case TInst(_.get() => cls = {kind:KTypeParameter(constraints)}, _):
                            if (func.params.filter( t -> t.name != cls.name).length == 0) {
                                func.params.push( {
                                    name: cls.name,
                                    constraints: constraints.map( t -> t.toComplexType() ),
                                } );

                            }

                        case _:

                    }
                    
                    func.args.push( {
                        name: _name, 
                        opt: arg.opt, 
                        type: switch arg.t {
                            case TInst(_.get() => cls = {kind:KTypeParameter(constraints)}, _):
                                if (constraints.length > 0) {
                                    constraints[0].toComplexType();

                                } else {
                                    TPath({name:cls.name, pack:[]});

                                }

                            case _:
                                arg.t.toComplexType();

                        }
                    } );

                }

                // The default expression is Void.
                var _expr:Expr = macro {};
                
                // Attempting to use `unify` causes `Variables of type Void are not allowed` to be thrown.
                if (ret.toString() != 'Void') {
                    var _ret:Expr = null;

                    // Prefer to return an argument instead of a default value, if possible.
                    for (i in 0...args.length) if (args[i].t.unify(ret)) {
                        _ret = macro $i{func.args[i].name};
                        break;
                    }

                    // If not, just return a default value.
                    if (_ret == null) _ret = basicType(ret, pos);

                    // Its not a basic type and its not a type in the `arg` list.
                    // So add it to the arg list, so it can `bind`ed later.
                    if (_ret.isNullExpr()) {
                        var index = func.args.push( {
                            name: genAscii(count++), 
                            opt: false, 
                            type: cret,
                        } ) - 1;
                        var _arg = func.args[index];
                        _ret = macro $i{_arg.name};

                    }

                    _expr = macro return $_ret;

                }

                func.ret = cret;
                func.expr = _expr;
                stack.addExprDef( EFunction(FNamed(_variable.name, false), func), type );

            case x:
                if (isDebug) {
                    trace( '---Uncaught case---');
                    trace( x );
                }

        }
        
        return stack;
    }

    // A...Z and a...z
    private static final codepoints:Array<Int> = [for (i in 'A'.code...'['.code) i].concat( [for (i in 'a'.code...'{'.code) i] );
    private static function genAscii(index:Int):String {
        if (index < 0) index = -index;
        var result = '';
        var max = codepoints.length-1;

        if (index > max) {
            while (index > max) {
                result += genAscii(index - max - result.length);
                index -= max;

            }

            index--;

        }
        
        result += String.fromCharCode( codepoints[index] );

        return result;
    }

    private static function basicType(type:Type, pos:Position):Expr {
        var result = macro @:pos(pos) null;
        
        switch type {
            case TAbstract(_.get() => {name:Default}, _params):
                result = basicType(_params[0], pos);

            case TInst(_.get() => cls, _params) if (cls.meta.has(Metas.CoreType) || cls.meta.has(Metas.CoreApi)):
                switch cls.name {
                    case 'Array': result = macro @:pos(pos) [];
                    case 'String': result = macro @:pos(pos) be.types.defaulting.Defaults.string;
                    case x: 
                        if (isDebug) trace( x );
                }

            case TAbstract(_.get() => abs, _params) if(abs.meta.has(Metas.CoreType) || abs.meta.has(Metas.CoreApi)):
                switch abs.name {
                    case 'Int': result = macro @:pos(pos) be.types.defaulting.Defaults.int;
                    case 'Float': result = macro @:pos(pos) be.types.defaulting.Defaults.float;
                    case 'Bool': result = macro @:pos(pos) be.types.defaulting.Defaults.bool;
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

            case TAbstract(_.get() => abs, _params) if (abs.from.length > 0):
                for (field in abs.from) if (field.field == null) {
                    result = basicType(field.t, pos);
                    if (!result.isNullExpr()) {
                        var ct = type.toComplexType();
                        result = macro ($result:$ct);
                        break;
                    }

                }

            case _:

        }

        return result;
    }

    public static inline function isNullExpr(v:Expr):Bool return switch v {
        case macro null: true;
        case _: false;
    }

    public static function detectCircularRef(type:Type, ?types:Array<Type>):Null<Type> {
        var result:Null<Type> = null;
        var list:Array<Type> = [];
        var types:Array<Type> = types == null ? [] : types;
        var stypes:Array<String> = types.map( t -> t.toString() );
        var current = type;

        while (current != null) {
            if (isDebug) trace( 'checking type: ' + current.toString() );
            var isCore:Bool = false;
            var isFunc:Bool = false;

            switch current {
                case TInst(_.get() => cls, p):
                    if (cls.meta.has(Metas.CoreApi) || cls.meta.has(Metas.CoreType)) {
                        isCore = true;
                    }

                    switch cls.kind {
                        case KNormal:
                            if (!isCore && cls.constructor != null) {
                                var ctor = cls.constructor.get();
                                ctor.type = ctor.type.applyTypeParameters( cls.params, p );
                                list.push( ctor.type.reduce() );

                            }

                        case KAbstractImpl(ref):
                            for (field in cls.statics.get()) if (field.name == '_new') {
                                switch field.type.reduce() {
                                    case TFun(args, _):
                                        /**
                                            Why is the return type ignored?
                                            ---
                                            As an abstract ctor its return type is itself,
                                            not `Void` like a class ctor, adding it to the
                                            list will cause a false positive.
                                        **/
                                        for (arg in args) list.push( arg.t );

                                    case x:
                                        list.push( x );

                                }
                                break;

                            }

                        case x:
                            if (isDebug) trace( x );

                    }

                case TAbstract(_.get() => abs, params):
                    if (abs.meta.has(Metas.CoreApi) || abs.meta.has(Metas.CoreType)) {
                        isCore = true;
                    }

                    if (!isCore) {
                        if (abs.impl != null) {
                            list.push( TInst(abs.impl, params) );

                        } else {
                            list.push( abs.type );

                        }

                    }

                case TFun(args, ret):
                    isFunc = true;
                    for (a in args) list.push(a.t);
                    list.push( ret );

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
                    if (isDebug) trace( x.toString() );

            }

            if (!isCore && !isFunc) {
                var index = -1;
                if ((index = stypes.lastIndexOf(current.toString())) == -1) {
                    types.push( current );
                    stypes.push( current.toString() );
                    
                } else {
                    if (isDebug) {
                        trace( 'loop detected.' );
                        trace( index, stypes, current.toString() );
                    }
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
                        //expr = macro $i{stack.typeVariable(arg.t).name};
                        //expr = {expr:stack.exprDef(arg.t), pos:pos};
                        switch stack.exprDef(arg.t) {
                            case EVars(vars):
                                expr = macro $i{vars[0].name};

                            case EFunction(FNamed(name, false), _):
                                expr = macro $i{name};

                            case _:

                        }

                    }

                    args.push( expr );

                }

            case x:
                if (isDebug) trace( x );

        }

        return args;
    }

    private static function varAccess(access:VarAccess, get:Bool):String {
        return switch access {
            case AccNo: 'null';
            case AccNever: 'never';
            case AccCall: get?'get':'set';
            case _: 'default';
        }
    }

}