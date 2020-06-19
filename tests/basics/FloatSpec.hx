package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class FloatSpec {

    public function new() {}

    public function test() {
        var a:Default<Float> = nil;

        asserts.assert( a != null );
        asserts.assert( a == .0 );

        return asserts.done();
    }

}