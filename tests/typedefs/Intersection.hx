package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class Intersection {

    public function new() {}

    public function test() {
        var a:Default<Def> = nil;

        #if !static
        asserts.assert( a != null );
        asserts.assert( a.a != null );
        #end
        asserts.assert( a.a == '' );
        #if !static
        asserts.assert( a.b != null );
        #end
        asserts.assert( a.b == 0 );
        #if !static
        var check = a.make != null;
        asserts.assert( check );
        var check = a.make('') != null;
        asserts.assert( check );
        #end

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