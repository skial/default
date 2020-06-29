package methods;

import be.types.NIL;
import be.types.Default;

using tink.CoreApi;

@:asserts
class ManyArgs {

    public function new() {}

    public function test() {

        var a:Default<
            Int->String->Float->Bool->String->Array<Float>->String->Int->
            Int->String->Float->Bool->String->Array<Float>->String->Int->
            Int->String->Float->Bool->String->Array<Float>->String->Int->
            Int->String->Float->Bool->String->Array<Float>->String->Int->
            Int->String->Float->Bool->String->Array<Float>->String->Int->Int> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( Error.catchExceptions( a.get()
            .bind(
                0, '1', 2, true, '4', [5, 6, 7, 8], '9', 10,
                0, '1', 2, true, '4', [5, 6, 7, 8], '9', 10,
                0, '1', 2, true, '4', [5, 6, 7, 8], '9', 10,
                0, '1', 2, true, '4', [5, 6, 7, 8], '9', 10,
                0, '1', 2, true, '4', [5, 6, 7, 8], '9', 10
            ) 
        ).isSuccess() );

        return asserts.done();
    }

}