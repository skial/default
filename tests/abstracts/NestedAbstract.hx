package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class NestedAbstract {

    public function new() {}

    public function test() {
        var v:Default<Abs0> = nil;

        #if !static
        asserts.assert( v != null );
        asserts.assert( v.a != null );
        #end
        asserts.assert( v.a == Std.string({foo:0}) );
        asserts.assert( v.self.b == 0 );

        return asserts.done();
    }

}

private abstract Abs0(Abs1) {

    public var a(get, never):String;
    private inline function get_a() return Std.string(this);
    public var self(get, never):Abs1;
    private inline function get_self() return this;

    public function new(v:Abs1) {
        this = v;
    }

}

private abstract Abs1({foo:Int}) {

    public var b(get, set):Int;
    private inline function get_b() return this.foo;
    private inline function set_b(v) return this.foo = v;

    public function new(v:Int) {
        this = {foo:v};
    }

}