package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class LocalMethod {

    public function new() {}

    public function test() {
        var a:Default<Foo> = nil;

        asserts.assert( a != null );
        asserts.assert( a.make != null );
        asserts.assert( a.make('hello') != null );

        return asserts.done();
    }

}

private typedef Foo = {
    dynamic function make(s:String):Foo;
}