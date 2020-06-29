package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class IntSpec {

    public function new() {}

    public function test() {
        var a:Default<Int> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a == 0 );

        return asserts.done();
    }

}