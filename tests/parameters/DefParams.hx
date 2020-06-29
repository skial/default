package parameters;

import be.types.NIL;
import be.types.Default;

@:asserts
class DefParams {

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

private typedef Foo<A> = {

    public var a:A;
}