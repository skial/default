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

class B {
    public var i:Int = 100;
    private inline function new() {

    }
}

@:asserts class DefaultClassSpec {

    public function new() {}

    public function testNormalCtor_Manual() {
        var a:A = new A('', 0, 0);

        asserts.assert( '' == a.a );
        asserts.assert( '' == a.b );
        asserts.assert( 0 == a.c );
        asserts.assert( 0 == a.d );
        asserts.assert( false == a.e );

        asserts.done();
        return asserts;
    }

    public function testDefaultCtor_Public() {
        var a:Default<A> = NIL;

        asserts.assert( '' == a.a );
        asserts.assert( '' == a.b );
        asserts.assert( 0 == a.c );
        asserts.assert( 0 == a.d );
        asserts.assert( false == a.e );

        asserts.done();
        return asserts;
    }

    public function testDefaultCtor_Private() {
        var b:Default<B> = nil;
        asserts.assert(b != null);
        asserts.assert(b.i == 100);
        asserts.done();
        return asserts;
    }

}