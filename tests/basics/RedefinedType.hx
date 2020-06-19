package basics;

import be.types.NIL;
import be.types.Default;

@:asserts
class RedefinedType {

    public function new() {}

    public function test() {
        var a:Default<Str> = nil;

        asserts.assert( a != null );
        asserts.assert( a == '' );

        return asserts.done();
    }

}

private typedef Str = String;