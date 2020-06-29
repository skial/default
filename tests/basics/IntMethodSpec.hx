package basics;

import be.types.NIL;
import be.types.Default;

using tink.CoreApi;

@:asserts
class IntMethodSpec {

    public function new() {}

    public function test() {
        var a:Default<Int->Int> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( Error.catchExceptions( a.get().bind(10) ).isSuccess() );

        return asserts.done();
    }

}