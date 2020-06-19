package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class SingleDefField {

    public function new() {}

    public function test() {
        var a:Default<Def> = NIL;

        asserts.assert( a != null );
        asserts.assert( a.foo != null );
        asserts.assert( a.foo == '' );

        return asserts.done();
    }

}

private typedef Def = {
    foo:String,
}