package classes;

import be.types.NIL;
import be.types.Default;

@:asserts
class SingleBasicField {

    public function new() {}

    public function test() {
        var v:Default<Cls> = nil;

        asserts.assert( v != null );
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