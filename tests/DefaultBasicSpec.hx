package ;

#if thx_core
import thx.Nil;
#end

import be.types.NIL;
import be.types.Default;

#if tink_core
using tink.CoreApi;
#end

abstract Path(String) from String to String {}

@:asserts
@:nullSafety
class DefaultBasicSpec {

    public static inline var HELLO:String = 'hello';
    public static inline var N1000:Int = 1000;
    public static inline var F1000:Float = 1000.123;

    public function new() {}

    public function testString() {
        var a:Default<String> = nil;
        var b:Default<String> = HELLO;
        
        asserts.assert('' == a);
        asserts.assert(HELLO == b);

        asserts.done();
        return asserts;
    }

    #if !static
    @:nullSafety(Off)
    public function testNullString() {
        var a:Default<String> = null;
        var b:Default<String> = HELLO;
        asserts.assert(a == null);
        asserts.assert(HELLO == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testInt() {
        var a:Default<Int> = NIL;
        var b:Default<Int> = N1000;
        asserts.assert(a == 0);
        asserts.assert(b == N1000);

        asserts.done();
        return asserts;
    }

    #if !static
    @:nullSafety(Off)
    public function testNullInt() {
        var a:Default<Int> = null;
        var b:Default<Int> = N1000;
        asserts.assert(a == null);
        asserts.assert(N1000 == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testFloat() {
        var a:Default<Float> = NIL;
        var b:Default<Float> = F1000;
        asserts.assert(a == .0);
        asserts.assert(b == F1000);

        asserts.done();
        return asserts;
    }

    #if !static
    @:nullSafety(Off)
    public function testNullFloat() {
        var a:Default<Float> = null;
        var b:Default<Float> = F1000;
        
        asserts.assert(a == null);
        asserts.assert(F1000 == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testObject() {
        var a:Default<{}> = NIL;
        var b:Default<{a:String}> = {a:'1'};
        
        asserts.assert( Reflect.fields( a.get() ).length == 0 );
        asserts.assert({a:'1'}.a == b.a);

        asserts.done();
        return asserts;
    }

    #if !static
    public function testNullObject() {
        @:nullSafety(Off)
        var a:Default<{}> = null;
        var b:Default<{a:String}> = {a:'1'};

        asserts.assert( Reflect.fields( a.get() ).length == 0 );
        asserts.assert({a:'1'}.a == b.a);

        asserts.done();
        return asserts;
    }
    #end

    public function testTypedObject() {
        var b:Default<{a:String}> = NIL;

        asserts.assert( {a:''}.a == b.a );

        asserts.done();
        return asserts;
    }

    // Currently doesnt build a matching struct at runtime.
    /*public function testNullTypedObject() {
        var b:Default<{a:String}> = null;
        asserts.assert('' + {a:''} == '' + b);

        asserts.done();
        return asserts;
    }*/

    public function testArray() {
        var a:Default<Array<String>> = NIL;
        var b:Default<Array<String>> = ['a', 'b'];

        asserts.assert( 0 == a.length );
        asserts.assert( 2 == b.length );
        asserts.assert('' + [] == '' + a);
        asserts.assert('' + ['a', 'b'] == '' + b);

        asserts.done();
        return asserts;
    }

    public function testAbstract_simple() {
        var path:Default<Path> = NIL;

        asserts.assert( '' == path );

        asserts.done();
        return asserts;
    }

    #if thx_core
    public function testString_thxcore() {
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
        var a:Default<String> = Noise;
        var b:Default<String> = HELLO;
        
        asserts.assert('' == a);
        asserts.assert(HELLO == b);

        asserts.done();
        return asserts;
    }
    #end

    public function testDynamicAccess() {
        var a:Default<haxe.DynamicAccess<String>> = NIL;

        asserts.assert( !a.exists('') );
        asserts.assert( 0 == a.keys().length, '' + a.keys() );

        asserts.done();
        return asserts;
    }

    /*#if !static
    public function testTinkJsonRepresentation() {
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
    #end*/

}