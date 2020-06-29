package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class BoolSpec {

    public function new() {}

    public function test() {
        var a:Default<Bool> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a == false );

        return asserts.done();
    }

}