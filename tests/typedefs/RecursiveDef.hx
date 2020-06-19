package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class RecursiveDef {

    public function new() {}

    public function test() {
        var a:Default<Def> = nil;

        asserts.assert( a != null );

        return asserts.done();
    }

}

private typedef Def = {
    foo:Foo,
}

private typedef Foo = {
    var a:Int;
    var b:String;
    var c:Def;
}