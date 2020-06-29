package basics;

import be.types.NIL;
import be.types.Default;

using tink.CoreApi;

@:asserts
class VoidMethodSpec {

    public function new() {}

    public function test() {

        var a:Default<Void->Void> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( Error.catchExceptions( a.get() ).isSuccess() );

        return asserts.done();
    }

}