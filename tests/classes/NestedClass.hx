package classes;

import be.types.NIL;
import be.types.Default;

@:asserts
class NestedClass {

    public function new() {}

    public function test() {
        var v:Default<Cls0> = nil;

        asserts.assert( v != null );
        asserts.assert( v.a != null );
        asserts.assert( v.a.b != null );
        asserts.assert( v.a.b == '' );

        return asserts.done();
    }

}

private class Cls0 {

    public var a:Cls1;

    public function new(_a:Cls1) {
        a = _a;
    }

}

private class Cls1 {

    public var b:String;

    public function new(_b:String) {
        b = _b;
    }

}