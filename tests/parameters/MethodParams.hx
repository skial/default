package parameters;

import be.types.NIL;
import be.types.Default;

using tink.CoreApi;

@:asserts
class MethodParams {

    public function new() {}

    public function test() {
        var a:Default<Foo<String>> = NIL;

        #if !static
        asserts.assert( a != null );
        asserts.assert( a.a != null );
        #end
        asserts.assert( Error.catchExceptions( a.a
            .bind( '', '', '' ) 
        ).isSuccess() );

        var b:Default<Foo<Int>> = nil;

        #if !static
        asserts.assert( b != null );
        asserts.assert( b.a != null );
        #end
        asserts.assert( Error.catchExceptions( b.a
            .bind( 0, 1, '' ) 
        ).isSuccess() );

        return asserts.done();
    }

}

private class Foo<A> {

    public var a:A->A->String->A;

    public function new(a:A->A->String->A) {
        this.a = a;
    }

}