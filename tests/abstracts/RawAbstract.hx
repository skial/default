package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class RawAbstract {

    public function new() {}

    public function test() {
        var v:Default<Abs> = nil;

        #if !static
        asserts.assert( v != null );
        #end
        asserts.assert( v.a == '' );

        return asserts.done();
    }

}

private abstract Abs(String) {

    public var a(get, never):String;
    private inline function get_a() return this;

}