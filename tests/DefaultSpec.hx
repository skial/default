package ;

import utest.Assert;
import be.types.NIL;
import be.types.Default;

@:enum private SConsts(String) from String to String {
    var Hello = 'hello';
}

@:enum private IConsts(Int) from Int to Int {
    var N1000 = 1000;
}

@:enum private FConsts(Float) from Float to Float {
    var F1000 = 1000.123;
}

class A {

    public var a:String;
    public var b:Default<String> = NIL;
    public var c:Int;
    public var d:Int;

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

    public function new() {}

    public function equals<T>(e:T, r:T) {
        Assert.equals(e, r);
    }

    public function same<T>(e:T, r:T) {
        Assert.same(e, r);
    }

    public function testString() {
        var a:Default<String> = NIL;
        var b:Default<String> = Hello;
        equals('', a);
        equals(Hello, b);
    }

    public function testNullString() {
        var a:Default<String> = null;
        var b:Default<String> = Hello;
        equals('', a);
        equals(Hello, b);
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

}