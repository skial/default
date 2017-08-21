package ;

import utest.Assert;
import be.types.NIL;
import be.types.Default;

#if thx_core
import thx.Nil;
#end

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

@:keep class DefaultSpec {

    public static inline var HELLO:String = 'hello';
    public static inline var N1000:Int = 1000;
    public static inline var F1000:Float = 1000.123;

    public function new() {}

    public inline function equals<T>(e:T, r:T) {
        Assert.equals(e, r);
    }

    public inline function same<T>(e:T, r:T) {
        Assert.same(e, r);
    }

    public function testString() {
        var a:Default<String> = NIL;
        var b:Default<String> = HELLO;
        
        equals('', a);
        equals(HELLO, b);
    }

    public function testNullString() {
        var a:Default<String> = null;
        var b:Default<String> = HELLO;
        equals('', a);
        equals(HELLO, b);
    }

    public function testInt() {
        var a:Default<Int> = NIL;
        var b:Default<Int> = N1000;
        equals(0, a);
        equals(N1000, b);
    }

    public function testNullInt() {
        var a:Default<Int> = null;
        var b:Default<Int> = N1000;
        equals(0, a);
        equals(N1000, b);
    }

    public function testFloat() {
        var a:Default<Float> = NIL;
        var b:Default<Float> = F1000;
        equals(.0, a);
        equals(F1000, b);
    }

    public function testNullFloat() {
        var a:Default<Float> = null;
        var b:Default<Float> = F1000;
        equals(.0, a);
        equals(F1000, b);
    }

    public function testObject() {
        var a:Default<{}> = NIL;
        var b:Default<{a:String}> = {a:'1'};
        same({}, a);
        same({a:'1'}, cast b);
    }

    public function testNullObject() {
        var a:Default<{}> = null;
        var b:Default<{a:String}> = {a:'1'};
        same({}, a);
        same({a:'1'}, cast b);
    }

    public function testTypedObject() {
        var b:Default<{a:String}> = NIL;
        same({a:''}, cast b);
    }

    // Currently doesnt build a matching struct at runtime.
    /*public function testNullTypedObject() {
        var b:Default<{a:String}> = null;
        same({a:''}, cast b);
    }*/

    public function testArray() {
        var a:Default<Array<String>> = NIL;
        var b:Default<Array<String>> = ['a', 'b'];
        Assert.equals( 0, a.length );
        Assert.equals( 2, b.length );
        Assert.equals('' + [], '' + a);
        Assert.equals('' + ['a', 'b'], '' + b);
    }

    public function testClasses() {
        var a:Default<A> = NIL;

        equals( '', a.a );
        equals( '', a.b );
        equals( 0, a.c );
        equals( 0, a.d );
        equals( false, a.e );
    }

    public function testTypedefs() {
        var c:Default<C> = NIL;

        equals( '', c.a );
        equals( 0, c.b );
        equals( .0, c.c );
        equals( '' + [], '' + c.d );

        equals( '', c.e.a );
        equals( 0, c.e.b );
        equals( .0, c.e.c );
        equals( '' + [], '' + c.e.d );
    }

    #if thx_core
    public function testString_thxcore() {
        var a:Default<String> = nil;
        var b:Default<String> = HELLO;
        
        equals('', a);
        equals(HELLO, b);
    }
    #end

    #if tink_core
    public function testString_tinkcore() {
        var a:Default<String> = Noise;
        var b:Default<String> = HELLO;
        
        equals('', a);
        equals(HELLO, b);
    }
    #end

}