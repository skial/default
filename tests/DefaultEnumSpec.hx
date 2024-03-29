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

enum D {
    Empty;
}

enum E {
    Arg3(a:Int, b:String, c:Float);
}

enum F {
    Loop(v:F);
    Ref(r:E);
}

@:asserts
@:nullSafety
class DefaultEnumSpec {

    public function new() {}

    public function testEnum_simple() {
        var d:Default<D> = NIL;
        
        asserts.assert( d.get().match(Empty) );

        return asserts.done();
    }

    public function testEnum_args() {
        var e:Default<E> = NIL;
        
        asserts.assert( e.get().match(Arg3(0, '', .0)) );

        return asserts.done();
    }

    @:nullSafety(Off)
    public function testEnum_loop() {
        var f:Default<F> = NIL;
        
        asserts.assert( f.get().match( Ref(Arg3(0, '', .0)) ) );

        return asserts.done();
    }

}