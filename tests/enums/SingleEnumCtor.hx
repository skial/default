package enums;

import be.types.NIL;
import be.types.Default;

@:asserts
class SingleEnumCtor {

    public function new() {}

    public function test() {
        var a:Default<Foo> = NIL;

        asserts.assert( a != null );
        asserts.assert( a.get().match(Ctor('', 0, .0, false)) );

        return asserts.done();
    }

}

private enum Foo {
    Ctor(a:String, b:Int, c:Float, d:Bool);
}