package be.types._default;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using tink.CoreApi;
using tink.MacroApi;
using be.macros.Default;
using haxe.macro.TypeTools;

/**
    macro @:mergeBlock $b{
        $exprs
        $assignments
    }
**/
@:structInit
class StackObj {
    // Contains the original types created by the compiler for each `exprdef` in `exprs`.
    // This is needed as ComplexTypes converted {back}to Types can fail.
    public var exprTypes:Array<Type> = [];
    // All declarations, variables, methods. Each value should be as complete
    // as possible.
    public var exprs:Array<ExprDef> = [];
    // Any objects that need to be set after all variables, methods etc have been
    // defined.
    public var assignments:Array<Expr> = [];
}

//@:forward(vars, fields)
@:forward(exprs, exprTypes, assignments)
abstract Stack(StackObj) from StackObj {

    public inline function new() this = { exprs: [], assignments: [], exprTypes: [] };

    public function typeIndex(t:Type):Int {
        //var ct = t.toComplexType();
        //return complexTypeIndex(ct);
        //trace( t.toString() );
        var i = this.exprs.length-1;
        while (i >= 0) {
        //for (i in 0...this.exprs.length) {
            //trace( i, this.exprTypes[i] );
            //trace( i );
            switch this.exprs[i] {
                case EVars(vars):
                    /*trace( v.type.toType() );
                    trace( v.type.toString() );*/
                    if (this.exprTypes[i] != null && (this.exprTypes[i].unify( t ) || this.exprTypes[i].unify( Context.follow(t, true) ))) return i;

                case EFunction(FNamed(n, false), method):
                    if (this.exprTypes[i] != null && (this.exprTypes[i].unify( t ) || this.exprTypes[i].unify( Context.follow(t, true) ))) return i;
                    /*trace( TFunction(method.args.map( a -> a.type), method.ret).toType() );
                    switch t {
                        case TFun(args, ret) if (method.args.length == args.length):
                            if (method.ret.toType().sure().unify(ret)) {
                                var bool = false;
                                for (i in 0...method.args.length) {
                                    bool = method.args[i].type.toType().sure().unify( args[i].t );
                                    if (!bool) break;
                                }
                                if (bool) return i;

                            }

                        case _:

                    }*/

                case _:

            }
            i--;

        }
        /*for (i in 0...this.vars.length) {
            if (Context.unify(this.vars[i].t, t)) return i;
        }*/
        return -1;
    }

    /*public function typeVariable(t:Type):Var {
        return this.vars[typeIndex(t)].v;
    }*/

    public inline function exprDef(t:Type):Null<ExprDef> {
        //return this.vars[typeIndex(t)].v;
        return this.exprs[typeIndex(t)];
    }

    public function addExprDef(def:ExprDef, t:Type):Int {
        var index = this.exprs.push(def) - 1;
        this.exprTypes[index] = t;
        return index;
    }

    public function addVariable(variable:Var, t:Type):Int {
        var index = -1;
        /*for (i in 0...this.vars.length) if (this.vars[i].v.name == v.name) {
            index = i;
            break;
        }

        if (index == -1) {
            index = this.vars.push( { v:v, t:t } );

        }*/
        //trace( 'looking for ${variable.name}...' );
        for (i in 0...this.exprs.length) switch this.exprs[i] {
            case EVars(vars):
                for (v in vars) if (v.name == variable.name) {
                    //trace( 'found ${variable.name} at index $i' );
                    return i;
                }

            case EFunction(kind, method):
                switch kind {
                    case FNamed(name, _) if (name == variable.name):
                        //trace( 'found ${variable.name} at index $i' );
                        return i;

                    case _:

                }

            case _:

        }
        //trace( variable.name + ' does not exist, adding to list. ');
        index = this.exprs.push( EVars([variable]) ) - 1;
        this.exprTypes[index] = t;

        return index;
    }

    public function addExpr(e:Expr):Int {
        //return this.fields.push( e );
        return this.assignments.push( e ) - 1;
    }

    public function snapshot(type:Type, pos:Position):Expr {
        // Unwrap the type if Default was passed in.
        switch type {
            case TAbstract(_.get() => {name:'Default'}, p):
                type = p[0];

            case _:

        }
        var result = macro null;
        var expr = exprDef(type);
        if (expr == null) {
            //trace( toString() );
            Context.fatalError( 'Type does not exist. ${type.toString()}', pos );
        }
        
        var rexpr = switch expr {
            case EVars(vars):
                macro $i{vars[0].name};

            case EFunction(FNamed(name, _), _):
                macro $i{name};

            case _:
                macro null;
        }

        /*trace( 
            this.exprs
            .map( d -> { expr:d, pos:pos } )
            .map( e -> e.toString() )
        );*/

        //trace( this.assignments.map( e -> e.toString() ) );
        //trace( rexpr.toString() );

        result = macro @:mergeBlock $b{
            this.exprs
                .map( d -> { expr:d, pos:pos } )
                .concat( this.assignments )
                .concat( [rexpr] )
        };
        /*// Make sure variables are correctly typed for static targets.
        for (variable in this.vars) {
            switch variable.v.type {
                case TPath({name:'Null'}):
                    
                case x if (variable.v.expr.isNullExpr()):
                    var ctype = variable.v.type;
                    variable.v.type = macro:Null<$ctype>;

            }
            
        }

        var variables = {
            expr:EVars(this.vars.map(p -> p.v)), pos:pos
        };

        var stack = [variables].concat( this.fields );

        if (this.vars.length > 0) {
            var index = typeIndex(type);
            var variable = this.vars[index];
            var ct = variable.v.type;//Context.toComplexType(variable.t);
            // See issue #20 - https://gitlab.com/b.e/default/-/issues/20
            //stack.push( macro @:pos(pos) @:nullSafety(false) ($i{this.vars[0].v.name}:$ct) );
            //stack.push( macro @:pos(pos) @:nullSafety(false) $i{this.vars[this.vars.length-1].v.name} );
            stack.push( macro @:pos(pos) @:nullSafety(Off) ($i{variable.v.name}:$ct) );
        }

        result = macro @:pos(pos) @:mergeBlock $b{stack};*/

        return result;
    }

    public function toString():String {
        var buffer = new StringBuf();
        var pos = Context.currentPos();
        if (this.exprs.length > 0) buffer.add( '### exprdef ###\n' );

        for (def in this.exprs) {
            buffer.add( ({expr:def, pos:pos}).toString() + '\n' );

        }

        if (this.assignments.length > 0) buffer.add( '### assignment ###\n' );
        for (expr in this.assignments) buffer.add( expr.toString() + '\n' );

        return buffer.toString();
    }

}