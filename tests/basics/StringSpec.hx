package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class StringSpec {

    public function new() {}

    public function test() {
        var a:Default<String> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a == '' );

        return asserts.done();
    }

}