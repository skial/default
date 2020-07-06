package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
// @see https://github.com/skial/default/issues/3
class Issue3 {

    public function new() {}

    public function test() {
        var d:Default<B_<String>> = nil;

        #if !static
        asserts.assert( d != null );
        #end
        asserts.assert( d.callerB() == '' );
        asserts.assert( d.makerA('') == d );

        return asserts.done();
    }

}

private typedef A_ = {
    dynamic function makerA<T>(v:T):A_;
}

private typedef B_<T> = {>A_,
    dynamic function callerB():T;
}