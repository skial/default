package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class LocalMethod {

    public function new() {}

    public function test() {
        var a:Default<Foo> = nil;
        
        #if !static
        asserts.assert( a != null );
        asserts.assert( a.make != null );
        #end
        asserts.assert( a.make('hello') != null );

        return asserts.done();
    }

}

private typedef Foo = {
    dynamic function make(s:String):Foo;
}