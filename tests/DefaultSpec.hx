package ;

import utest.Assert;
import be.types.NILL;
import be.types.Default;

@:keep class DefaultSpec {

    public function new() {

    }

    public function equals<T>(e:T, r:T) {
        Assert.equals(e, r);
    }

    public function same<T>(e:T, r:T) {
        Assert.same(e, r);
    }

    public function testString() {
        var a:Default<String> = NILL;
        var b:Default<String> = 'hello';
        equals('', a);
        equals('hello', b);
    }

    public function testNullString() {
        var a:Default<String> = null;
        var b:Default<String> = 'hello';
        equals('', a);
        equals('hello', b);
    }

    public function testInt() {
        var a:Default<Int> = NILL;
        var b:Default<Int> = 1000;
        equals(0, a);
        equals(1000, b);
    }

    public function testNullInt() {
        var a:Default<Int> = null;
        var b:Default<Int> = 1000;
        equals(0, a);
        equals(1000, b);
    }

    public function testFloat() {
        var a:Default<Float> = NILL;
        var b:Default<Float> = 1000.123;
        equals(.0, a);
        equals(1000.123, b);
    }

    public function testNullFloat() {
        var a:Default<Float> = null;
        var b:Default<Float> = 1000.123;
        equals(.0, a);
        equals(1000.123, b);
    }

    public function testObject() {
        var a:Default<{}> = NILL;
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
        var b:Default<{a:String}> = NILL;
        same({a:''}, cast b);
    }

    // Currently doesnt build a matching struct at runtime.
    /*public function testNullTypedObject() {
        var b:Default<{a:String}> = null;
        same({a:''}, cast b);
    }*/

    public function testArray() {
        var a:Default<Array<String>> = NILL;
        var b:Default<Array<String>> = ['a', 'b'];
        Assert.equals( 0, a.length );
        Assert.equals( 2, b.length );
        Assert.equals('' + [], '' + a);
        Assert.equals('' + ['a', 'b'], '' + b);
    }

}