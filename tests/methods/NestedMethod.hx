package methods;

import be.types.NIL;
import be.types.Default;

using tink.CoreApi;

@:asserts
class NestedMethod {

    public function new() {}

    public function test() {
        var a:Default<Int->(Int->Void)->Void> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( Error.catchExceptions( a.get()
            .bind( 0, function(_) {} ) 
        ).isSuccess() );

        return asserts.done();
    }

}