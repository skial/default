package be.types.defaulting;

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
        var i = this.exprs.length-1;

        while (i >= 0) {
            switch this.exprs[i] {
                case EVars(vars):
                    /*trace( v.type.toType() );
                    trace( v.type.toString() );*/
                    if (this.exprTypes[i] != null && (this.exprTypes[i].unify( t ) || this.exprTypes[i].unify( Context.follow(t, true) ))) return i;

                case EFunction(FNamed(n, false), method):
                    if (this.exprTypes[i] != null && (this.exprTypes[i].unify( t ) || this.exprTypes[i].unify( Context.follow(t, true) ))) return i;
                    

                case _:

            }
            i--;

        }

        return -1;
    }

    public inline function exprDef(t:Type):Null<ExprDef> {
        return this.exprs[typeIndex(t)];
    }

    public function addExprDef(def:ExprDef, t:Type):Int {
        var index = this.exprs.push(def) - 1;
        this.exprTypes[index] = t;
        return index;
    }

    public function addVariable(variable:Var, t:Type):Int {
        var index = -1;
        
        for (i in 0...this.exprs.length) switch this.exprs[i] {
            case EVars(vars):
                for (v in vars) if (v.name == variable.name) {
                    return i;
                }

            case EFunction(kind, method):
                switch kind {
                    case FNamed(name, _) if (name == variable.name):
                        return i;

                    case _:

                }

            case _:

        }
        
        index = this.exprs.push( EVars([variable]) ) - 1;
        this.exprTypes[index] = t;

        return index;
    }

    public function addExpr(e:Expr):Int {
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