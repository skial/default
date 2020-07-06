package ;

import be.types.NIL;
import be.types.Default;

#if tink_core
using tink.CoreApi;
#end

typedef Ref = {
    ref:Ref,
}

typedef RefFunc = {
    ref:Void->RefFunc,
}

typedef A_ = {
    dynamic function makeA<T>(v:T):A_;
}

typedef B_<T> = {>A_,
    dynamic function callB():T;
}

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

@:asserts
/*@:nullSafety*/
class DefaultTypedefSpec {

    public function new() {}

    public function testSingleField_object() {
        var foo:Default<{foo:Int}> = nil;
        #if !static
        @:nullSafety(Off)
        asserts.assert( foo != null );
        @:nullSafety(Off)
        asserts.assert( foo.foo != null );
        #end
        asserts.assert( foo.foo == 0 );
        return asserts.done();

    }

    public function testCircular_typedef() {
        var foo:Default<Ref> = nil;
        #if !static
        @:nullSafety(Off)
        asserts.assert( foo != null );
        @:nullSafety(Off)
        asserts.assert( foo.ref != null );
        #end
        asserts.assert( foo.ref.ref == foo.ref.ref.ref.ref );
        return asserts.done();
    }

    #if !static
    public function testCircularCall_typedef() {
        var foo:Default<RefFunc> = nil;
        @:nullSafety(Off)
        asserts.assert( foo != null );
        @:nullSafety(Off)
        asserts.assert( foo.ref() != null );
        return asserts.done();
    }
    #end

    public function testTypedefs() {
        var c:Default<C> = NIL;
        
        asserts.assert( '' == c.a );
        asserts.assert( 0 == c.b );
        asserts.assert( .0 == c.c );
        asserts.assert( '' + [] == '' + c.d );

        #if !static
        @:nullSafety(Off)
        asserts.assert( c.e != null );
        #end
        asserts.assert( '' == c.e.a );
        asserts.assert( 0 == c.e.b );
        asserts.assert( .0 == c.e.c );
        asserts.assert( c.e.d.length == 0 );

        return asserts.done();
    }

    public function testTypedefAlias_simple() {
        var h:Default<H> = NIL;

        asserts.assert( '' == h );

        return asserts.done();
    }

    public function testTypedefAlias_descendant() {
        var i:Default<I> = NIL;

        asserts.assert( '' == i.a );

        return asserts.done();
    }

    public function testTypedefAlias_descendants() {
        var j:Default<J> = NIL;

        asserts.assert( '' == j.a.a );

        return asserts.done();
    }

    public function testTypedefAlias_module() {
        var f:Default<TFoo> = NIL;

        asserts.assert( '' == f );

        return asserts.done();
    }

    public function testTypedefAlias_module_descendants() {
        var f:Default<TFoo.TBar> = NIL;

        asserts.assert( '' == f.twins.a );
        asserts.assert( '' == f.twins.b );

        return asserts.done();
    }

    public function testIssue17() {
        var f:Default<B_<Int>> = nil;

        #if !static
        @:nullSafety(Off)
        asserts.assert( f != null );
        @:nullSafety(Off)
        asserts.assert( f.makeA(0) != null );
        @:nullSafety(Off)
        asserts.assert( f.makeA(10000).makeA(9) != null );
        #end
        asserts.assert( f.callB() == 0 );

        return asserts.done();
    }

}