package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class SingleDefField {

    public function new() {}

    public function test() {
        var a:Default<Def> = NIL;

        #if !static
        asserts.assert( a != null );
        asserts.assert( a.foo != null );
        #end
        asserts.assert( a.foo == '' );

        return asserts.done();
    }

}

private typedef Def = {
    foo:String,
}