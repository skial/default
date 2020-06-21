package basics;

import be.types.NIL;
import be.types.Default;
import haxe.DynamicAccess;

@:asserts
class ObjectSpec {

    public function new() {}

    public function test() {
        var a:Default<{}> = nil;

        asserts.assert( a != null );
        asserts.assert( Reflect.isObject(a) );

        return asserts.done();
    }

    public function testDynamicAccess() {
        var a:Default<DynamicAccess<String>> = NIL;

        asserts.assert( !a.exists('foo') );

        return asserts.done();
    }

}