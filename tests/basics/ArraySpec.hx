package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class ArraySpec {

    public function new() {}

    public function test() {
        var a:Default<Array<Bool>> = nil;

        #if !static
        asserts.assert( a != null );
        // The `get` access is annoying.
        asserts.assert( a.get()[0] == null );
        #else
        asserts.assert( a.get()[0] == false );
        #end
        asserts.assert( a.length == 0 );

        return asserts.done();
    }

}