package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class Intersection {

    public function new() {}

    public function test() {
        var a:Default<Def> = nil;

        asserts.assert( a != null );
        asserts.assert( a.a != null );
        asserts.assert( a.a == '' );
        asserts.assert( a.b != null );
        asserts.assert( a.b == 0 );
        var check = a.make != null;
        asserts.assert( check );
        var check = a.make('') != null;
        asserts.assert( check );

        return asserts.done();
    }

}

private typedef Foo = {
    dynamic function make<T>(v:T):Foo;
}

private typedef Def = {
    a:String,
} & {
    b:Int,
} & Foo;