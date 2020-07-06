package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class RedefinedType {

    public function new() {}

    public function test() {
        var a:Default<Str> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a == '' );

        return asserts.done();
    }

    public function testFromModule() {
        var a:Default<TFoo> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a == '' );

        return asserts.done();
    }

}

private typedef Str = String;