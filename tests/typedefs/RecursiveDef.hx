package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class RecursiveDef {

    public function new() {}

    public function test001() {
        var a:Default<Def> = nil;

        asserts.assert( a != null );
        asserts.assert( a.foo != null );
        asserts.assert( a.foo.a == 0 );
        asserts.assert( a.foo.b == '' );
        asserts.assert( a.foo.c != null );

        return asserts.done();
    }

    public function test002() {
        var a:Default<Ouroboros> = NIL;

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

// 🐍
private typedef Ouroboros = {
    var s:Ouroboros;
}