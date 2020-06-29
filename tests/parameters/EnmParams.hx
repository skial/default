package parameters;

import be.types.NIL;
import be.types.Default;

@:asserts
class EnmParams {

    public function new() {}

    public function test() {
        var a:Default<Foo<String>> = NIL;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a.match( One('') ) );

        var b:Default<Foo<Int>> = nil;

        #if !static
        asserts.assert( b != null );
        #end
        asserts.assert( b.match( One(0) ) );

        return asserts.done();
    }

}

private enum Foo<A> {
    One(a:A);
    Two(a:A, b:A);
}