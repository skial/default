package ;

#if thx_core
import thx.Nil;
#end

import tink.unit.AssertionBuffer;

import be.types.NIL;
import be.types.Default;

#if tink_core
using tink.CoreApi;
#end

class A {

    public var a:String;
    public var b:Default<String> = NIL;
    public var c:Int;
    public var d:Int;
    public var e:Default<Bool> = NIL;

    public function new(a:String, ?c:Int, ?d:Default<Int>) {
        this.a = a;
        this.c = c;
        this.d = d;
    }

}

class DefaultClassSpec {

    public function new() {}

    public function testNormalInit_Classes() {
        var asserts = new AssertionBuffer();

        var a:A = new A('', 0, 0);

        asserts.assert( '' == a.a );
        asserts.assert( '' == a.b );
        asserts.assert( 0 == a.c );
        asserts.assert( 0 == a.d );
        asserts.assert( false == a.e );

        asserts.done();
        return asserts;
    }

    public function testDefaultInit_Classes() {
        var asserts = new AssertionBuffer();

        var a:Default<A> = NIL;

        asserts.assert( '' == a.a );
        asserts.assert( '' == a.b );
        asserts.assert( 0 == a.c );
        asserts.assert( 0 == a.d );
        asserts.assert( false == a.e );

        asserts.done();
        return asserts;
    }

}