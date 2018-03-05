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

typedef C = {
    var a:String;
    var b:Default<Int>;
    var c(default, default):Float;
    var d(default, default):Default<Array<Int>>;
    var e:C;
}

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

typedef G = {
    var a:Default<Path>;
}

typedef H = String;

typedef I = {
    var a:H;
}

typedef J = {
    var a:I;
}

abstract Path(String) from String to String {}

@:keep class DefaultSpec {

    public static inline var HELLO:String = 'hello';
    public static inline var N1000:Int = 1000;
    public static inline var F1000:Float = 1000.123;

    public function new() {}

    public function testString() {
        var asserts = new AssertionBuffer();

        var a:Default<String> = nil;
        var b:Default<String> = HELLO;
        
        asserts.assert('' == a);
        asserts.assert(HELLO == b);

        asserts.done();
        return asserts;
    }

    #if !static
    public function testNullString() {
        var asserts = new AssertionBuffer();

        var a:Default<String> = null;
        var b:Default<String> = HELLO;
        asserts.assert(a == '');
        asserts.assert(HELLO == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testInt() {
        var asserts = new AssertionBuffer();

        var a:Default<Int> = NIL;
        var b:Default<Int> = N1000;
        asserts.assert(a == 0);
        asserts.assert(b == N1000);

        asserts.done();
        return asserts;
    }

    #if !static
    public function testNullInt() {
        var asserts = new AssertionBuffer();

        var a:Default<Int> = null;
        var b:Default<Int> = N1000;
        asserts.assert(a == 0);
        asserts.assert(N1000 == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testFloat() {
        var asserts = new AssertionBuffer();

        var a:Default<Float> = NIL;
        var b:Default<Float> = F1000;
        asserts.assert(a == .0);
        asserts.assert(b == F1000);

        asserts.done();
        return asserts;
    }

    #if !static
    public function testNullFloat() {
        var asserts = new AssertionBuffer();

        var a:Default<Float> = null;
        var b:Default<Float> = F1000;
        
        asserts.assert(a == .0);
        asserts.assert(F1000 == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testObject() {
        var asserts = new AssertionBuffer();

        var a:Default<{}> = NIL;
        var b:Default<{a:String}> = {a:'1'};
        
        asserts.assert( Reflect.fields( a.get() ).length == 0 );
        asserts.assert({a:'1'}.a == b.a);

        asserts.done();
        return asserts;
    }

    #if !static
    public function testNullObject() {
        var asserts = new AssertionBuffer();

        var a:Default<{}> = null;
        var b:Default<{a:String}> = {a:'1'};

        asserts.assert( Reflect.fields( a.get() ).length == 0 );
        asserts.assert({a:'1'}.a == b.a);

        asserts.done();
        return asserts;
    }
    #end

    public function testTypedObject() {
        var asserts = new AssertionBuffer();

        var b:Default<{a:String}> = NIL;

        asserts.assert( {a:''}.a == b.a );

        asserts.done();
        return asserts;
    }

    // Currently doesnt build a matching struct at runtime.
    /*public function testNullTypedObject() {
        var asserts = new AssertionBuffer();

        var b:Default<{a:String}> = null;
        same({a:''}, cast b);

        asserts.done();
        return asserts;
    }*/

    public function testArray() {
        var asserts = new AssertionBuffer();

        var a:Default<Array<String>> = NIL;
        var b:Default<Array<String>> = ['a', 'b'];

        asserts.assert( 0 == a.length );
        asserts.assert( 2 == b.length );
        asserts.assert('' + [] == '' + a);
        asserts.assert('' + ['a', 'b'] == '' + b);

        asserts.done();
        return asserts;
    }

    public function testClasses() {
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

    public function testTypedefs() {
        var asserts = new AssertionBuffer();

        var c:Default<C> = NIL;

        asserts.assert( '' == c.a );
        asserts.assert( 0 == c.b );
        asserts.assert( .0 == c.c );
        asserts.assert( '' + [] == '' + c.d );

        asserts.assert( '' == c.e.a );
        asserts.assert( 0 == c.e.b );
        asserts.assert( .0 == c.e.c );
        asserts.assert( '' + [] == '' + c.e.d );

        asserts.done();
        return asserts;
    }

    public function testEnum_simple() {
        var asserts = new AssertionBuffer();

        var d:Default<D> = NIL;
        
        asserts.assert( d.get().match(Empty) );

        asserts.done();
        return asserts;
    }

    public function testEnum_args() {
        var asserts = new AssertionBuffer();

        var e:Default<E> = NIL;
        
        asserts.assert( e.get().match(Arg3(0, '', .0)) );

        asserts.done();
        return asserts;
    }

    public function testEnum_loop() {
        var asserts = new AssertionBuffer();

        var f:Default<F> = NIL;
        
        asserts.assert( f.get().match( Ref(Arg3(0, '', .0)) ) );

        asserts.done();
        return asserts;
    }

    public function testAbstract_simple() {
        var asserts = new AssertionBuffer();

        var path:Default<Path> = NIL;

        asserts.assert( '' == path );

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

    #if thx_core
    public function testString_thxcore() {
        var asserts = new AssertionBuffer();

        var a:Default<String> = nil;
        var b:Default<String> = HELLO;
        
        asserts.assert('' == a);
        asserts.assert(HELLO == b);

        asserts.done();
        return asserts;
    }
    #end

    #if tink_core
    public function testString_tinkcore() {
        var asserts = new AssertionBuffer();

        var a:Default<String> = Noise;
        var b:Default<String> = HELLO;
        
        asserts.assert('' == a);
        asserts.assert(HELLO == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testDynamicAccess() {
        var asserts = new AssertionBuffer();

        var a:Default<haxe.DynamicAccess<String>> = NIL;

        asserts.assert( !a.exists('') );
        asserts.assert( 0 == a.keys().length, '' + a.keys() );

        asserts.done();
        return asserts;
    }

    #if !static
    public function testTinkJsonRepresentation() {
        var asserts = new AssertionBuffer();

        var s:Default<{foo:String, bar:Int}> = NIL;
        s.bar = 100;
        var j = tink.Json.stringify(s);

        asserts.assert( '{"bar":100,"foo":""}' == j );

        var s:{foo:Default<String>, bar:Default<Int>} = tink.Json.parse( j );

        asserts.assert( '' == s.foo );
        asserts.assert( 100 == s.bar );

        asserts.done();
        return asserts;
    }
    #end

}