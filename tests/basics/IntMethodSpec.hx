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
        // @see https://github.com/HaxeFoundation/haxe/issues/9685
        asserts.assert( Error.catchExceptions( a.get().bind(10) ).isSuccess() );

        return asserts.done();
    }

}