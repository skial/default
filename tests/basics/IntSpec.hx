package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class IntSpec {

    public function new() {}

    public function test() {
        var a:Default<Int> = nil;

        asserts.assert( a != null );
        asserts.assert( a == 0 );

        return asserts.done();
    }

}