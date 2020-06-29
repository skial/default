package parameters;

import be.types.NIL;
import be.types.Default;

@:asserts
class AbsParams {

    public function new() {}

    public function test() {
        var a:Default<Foo<String>> = NIL;

        #if !static
        asserts.assert( a != null );
        asserts.assert( a.a != null );
        #end
        asserts.assert( a.a == '' );

        var b:Default<Foo<Int>> = nil;

        #if !static
        asserts.assert( b != null );
        asserts.assert( b.a != null );
        #end
        asserts.assert( b.a == 0 );

        return asserts.done();
    }

}

private abstract Foo<A>(A) {

    public var a(get, set):A;
    private inline function get_a() return this;
    private inline function set_a(v) return this = v;

    public function new(a:A) {
        this = a;
    }

}