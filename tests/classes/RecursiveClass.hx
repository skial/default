package classes;

import be.types.NIL;
import be.types.Default;

@:asserts
class RecursiveClass {

    public function new() {}

    public function test() {
        var v:Default<A> = nil;

        #if !static
        asserts.assert( v != null );
        asserts.assert( v.str != null );
        #end
        /**
            Class A, field `str` has an initializer, so its set before
            returning the empty class.
        **/
        asserts.assert( v.str == '' );
        /**
            Class A, field `a` has no initializer so will be null,
            as the ctor is not called.
        **/
        #if !static
        asserts.assert( v.a == null );
        #end
        //asserts.assert( v.a != null );
        //asserts.assert( v.a.b != null );

        return asserts.done();
    }

}

private class A {

    public var a:B;
    public var str:String = '';

    public function new(_a:B, _s:String) {
        a = _a;
        str = _s;
    }

}

private class B {

    public var b:A;

    public function new(_b:A) {
        b = _b;
    }

}