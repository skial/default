package parameters;

import be.types.NIL;
import be.types.Default;

@:asserts
class ClsParams {

    public function new() {}

    public function test() {
        var a:Default<Foo<String>> = NIL;

        asserts.assert( a != null );
        asserts.assert( a.a != null );
        asserts.assert( a.a == '' );

        var b:Default<Foo<Int>> = nil;

        asserts.assert( b != null );
        asserts.assert( b.a != null );
        asserts.assert( b.a == 0 );

        return asserts.done();
    }

}

private class Foo<A> {

    public var a:A;

    public function new(a:A) {
        this.a = a;
    }

}