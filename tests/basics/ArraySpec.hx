package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class ArraySpec {

    public function new() {}

    public function test() {
        var a:Default<Array<Bool>> = nil;

        asserts.assert( a != null );
        asserts.assert( a.length == 0 );
        // The `get` access is annoying.
        asserts.assert( a.get()[0] == null );

        return asserts.done();
    }

}