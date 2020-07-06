package ;

import tink.unit.AssertionBuffer;

import be.types.NIL;
import be.types.Default;

#if tink_core
using tink.CoreApi;
#end

class A {

    public var a:String;
    public var b:Default<String> = nil;
    public var c:Int;
    public var d:Int;
    public var e:Default<Bool> = nil;

    public function new(a:String, ?c:Int, ?d:Int) {
        this.a = a;
        this.c = c == null ? 10 : c;
        this.d = c == null ? 0  : d;
    }

}

@:nullSafety class B {
    public var i:Int = 100;
    private inline function new() {}
}

@:nullSafety @:asserts class DefaultClassSpec {

    public function new() {}

    public function testNormalCtor_Manual() {
        var a:A = new A('', 0, 0);

        asserts.assert( '' == a.a );
        asserts.assert( '' == a.b );
        asserts.assert( 0 == a.c );
        asserts.assert( 0 == a.d );
        asserts.assert( false == a.e );

        return asserts.done();
    }

    public function testDefaultCtor_Public() {
        var a:Default<A> = NIL;

        asserts.assert( '' == a.a );
        asserts.assert( '' == a.b );
        // As `c` is optional, its not filled in by Default.
        asserts.assert( 10 == a.c );
        asserts.assert( 0 == a.d );
        asserts.assert( false == a.e );

        return asserts.done();
    }

    public function testDefaultCtor_Private() {
        var b:Default<B> = nil;
        #if !static
        @:nullSafety(Off) 
        asserts.assert(b != null);
        #end
        asserts.assert(b.i == 100);
        return asserts.done();
    }

}