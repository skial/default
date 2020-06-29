package enums;

import be.types.NIL;
import be.types.Default;

@:asserts
class SingleEnumField {

    public function new() {}

    public function test() {
        var a:Default<Foo> = NIL;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a.get().match(Empty) );

        return asserts.done();
    }

}

private enum Foo {
    Empty;
}