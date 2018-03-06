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

typedef C = {
    var a:String;
    var b:Default<Int>;
    var c(default, default):Float;
    var d(default, default):Default<Array<Int>>;
    var e:C;
}

typedef G = {
    var a:Default<DefaultBasicSpec.Path>;
}

typedef H = String;

typedef I = {
    var a:H;
}

typedef J = {
    var a:I;
}

class DefaultTypedefSpec {

    public function new() {}

    public function testTypedefs() {
        var asserts = new AssertionBuffer();

        var c:Default<C> = NIL;

        asserts.assert( '' == c.a );
        asserts.assert( 0 == c.b );
        asserts.assert( .0 == c.c );
        asserts.assert( '' + [] == '' + c.d );

        asserts.assert( c.e != null );
        asserts.assert( '' == c.e.a );
        asserts.assert( 0 == c.e.b );
        asserts.assert( .0 == c.e.c );
        asserts.assert( c.e.d.length == 0 );

        asserts.done();
        return asserts;
    }

    public function testTypedefAlias_simple() {
        var asserts = new AssertionBuffer();

        var h:Default<H> = NIL;

        asserts.assert( '' == h );

        asserts.done();
        return asserts;
    }

    public function testTypedefAlias_descendant() {
        var asserts = new AssertionBuffer();

        var i:Default<I> = NIL;

        asserts.assert( '' == i.a );

        asserts.done();
        return asserts;
    }

    public function testTypedefAlias_descendants() {
        var asserts = new AssertionBuffer();

        var j:Default<J> = NIL;

        asserts.assert( '' == j.a.a );

        asserts.done();
        return asserts;
    }

    public function testTypedefAlias_module() {
        var asserts = new AssertionBuffer();

        var f:Default<TFoo> = NIL;

        asserts.assert( '' == f );

        asserts.done();
        return asserts;
    }

    public function testTypedefAlias_module_descendants() {
        var asserts = new AssertionBuffer();

        var f:Default<TFoo.TBar> = NIL;

        asserts.assert( '' == f.twins.a );
        asserts.assert( '' == f.twins.b );

        asserts.done();
        return asserts;
    }

}