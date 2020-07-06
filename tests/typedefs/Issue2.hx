package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
// @see https://github.com/skial/default/issues/2
class Issue2 {

    public function new() {}

    public function test() {
        var d:Default<C> = nil;

        #if !static
        asserts.assert( d != null );
        #end
        asserts.assert( d.a == '' );
        asserts.assert( d.b == 0 );

        return asserts.done();
    }

}

private typedef C = {
    var a:String;
    var b:Default<Int>;
    var c(default, default):Float;
    var e:C;
}