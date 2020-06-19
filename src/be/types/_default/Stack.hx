package be.types._default;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using tink.CoreApi;
using tink.MacroApi;
using haxe.macro.TypeTools;

@:structInit
class StackObj {
    // All variables declarations, stored with the original compiler type.
    public var vars:Array<{v:Var, t:Type}> = [];
    // Fields that _still_ need to be set.
    public var fields:Array<Expr> = [];
}

@:forward(vars, fields)
abstract Stack(StackObj) from StackObj {

    public inline function new() this = { vars:[], fields:[] };

    public function typeIndex(t:Type):Int {
        for (i in 0...this.vars.length) {
            if (Context.unify(this.vars[i].t, t)/* || Context.unify(this.vars[i].v.type.toType().sure(), t)*/) return i;
        }
        return -1;
    }

    public function typeVariable(t:Type):Var {
        return this.vars[typeIndex(t)].v;
    }

    public function addVariable(v:Var, t:Type):Int {
        var index = -1;
        for (i in 0...this.vars.length) if (this.vars[i].v.name == v.name) {
            index = i;
            break;
        }

        if (index == -1) {
            index = this.vars.push( { v:v, t:t } );

        }

        /*switch t {
            case TInst(_.get() => cls, _) if (cls.constructor != null):
                var ctor = cls.constructor.get();
                switch ctor.type {
                    case TFun(args, _):
                        var links = [];
                        for (arg in args) for (i in 0...index) if (Context.unify(arg.t, this.vars[i].t)) {
                            if (i < index) {
                                Context.fatalError(
                                    Errors.CircularDependency.replace('::a::', arg.t.toString()).replace('::b::', t.toString()), 
                                    this.vars[i].v.expr.pos
                                );
                            }
                        }

                    case _:
                        

                }

            case x:
                trace( x );

        }*/

        return index;
    }

    public function addExpr(e:Expr):Int {
        return this.fields.push( e );
    }

    public function snapshot(type:Type, pos:Position):Expr {
        var result = macro null;
        var variables = {
            expr:EVars(this.vars.map(p -> p.v)), pos:pos
        };

        var stack = [variables].concat( this.fields );

        if (this.vars.length > 0) {
            var ct = Context.toComplexType(this.vars[0].t);
            // See issue #20 - https://gitlab.com/b.e/default/-/issues/20
            //stack.push( macro @:pos(pos) @:nullSafety(false) ($i{this.vars[0].v.name}:$ct) );
            //stack.push( macro @:pos(pos) @:nullSafety(false) $i{this.vars[this.vars.length-1].v.name} );
            stack.push( macro @:pos(pos) @:nullSafety(false) $i{typeVariable(type).name} );
        }

        /*result = {
            expr:EBlock(stack),
            pos:pos,
        }*/

        result = macro @:pos(pos) @:mergeBlock $b{stack};

        return result;
    }

    public function toString():String {
        var buffer = new StringBuf();
        if (this.vars.length > 0) buffer.add( '### variables ###\n' );
        for (variable in this.vars) {
            buffer.add( 'var ${variable.v.name}:${variable.t.toString()} = ${variable.v.expr.toString()};\n' );

        }

        if (this.fields.length > 0) buffer.add( '### fields ###\n' );
        for (expr in this.fields) buffer.add( expr.toString() + '\n' );
        return buffer.toString();
    }

}