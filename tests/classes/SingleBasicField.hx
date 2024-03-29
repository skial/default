package classes;

import be.types.NIL;
import be.types.Default;

@:asserts
class SingleBasicField {

    public function new() {}

    public function test() {
        var v:Default<Cls> = nil;

        #if !static
        asserts.assert( v != null );
        #end
        asserts.assert( v.a == '' );

        return asserts.done();
    }

}

private class Cls {

    public var a:String;

    public function new(_a:String) {
        a = _a;
    }

}