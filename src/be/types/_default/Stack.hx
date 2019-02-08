package be.types._default;

import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.Context;

using tink.CoreApi;
using tink.MacroApi;

typedef TStack = {
    // All variables defined. Stored with the original compiler type.
    vars:Array<{v:Var, t:Type}>,
    // Fields that _still_ need to be set. Think circular refs.
    fields:Array<Expr>,
}

@:forward abstract Stack(TStack) from TStack {

    public inline function new() this = {vars:[], fields:[]};

    @:op(A + B) public function merge(other:Stack):Stack {
        for (v in other.vars) this.vars.push(v);
        for (f in other.fields) this.fields.push(f);
        return this;
    }

    public function snapshot(pos:Position):Expr {
        var result = macro null;
        var variables = {
            expr:EVars(this.vars.map(p -> p.v)), pos:pos
        };

        var stack = [variables].concat( this.fields );

        if (this.vars.length > 0) stack.push( macro $i{this.vars[0].v.name} );

        result = {
            expr:EBlock(stack),
            pos:pos,
        }

        return result;
    }

}