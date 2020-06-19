package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class BoolSpec {

    public function new() {}

    public function test() {
        var a:Default<Bool> = nil;

        asserts.assert( a != null );
        asserts.assert( a == false );

        return asserts.done();
    }

}