package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class LocalTypeParam {

    public function new() {}

    public function test() {
        var a:Default<Foo> = nil;
        #if !static
        asserts.assert( a != null );
        #end
        // see https://github.com/HaxeFoundation/haxe/issues/9661
        var check:Bool = a.maker != null;
        asserts.assert( check );

        return asserts.done();
    }

}

// @see https://github.com/HaxeFoundation/haxe/issues/9662
private typedef Foo = {
    // Renaming to from `make` to `maker` gets around issue.
    dynamic function maker<T>(v:T):Foo;
}