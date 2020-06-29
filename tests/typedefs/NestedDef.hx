package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class NestedDef {

    public function new() {}

    public function test() {
        var a:Default<Def> = NIL;

        #if !static
        asserts.assert( a != null );
        asserts.assert( a.foo != null );
        asserts.assert( a.foo.a != null );
        #end
        asserts.assert( a.foo.a == 0 );
        #if !static
        asserts.assert( a.foo.b == null );
        // `a.foo.b` has `@:optional` meta, so its skipped & left as `null`.
        //asserts.assert( a.foo.b == '' );
        asserts.assert( a.foo.c != null );
        #end
        asserts.assert( a.foo.c == .0 );

        return asserts.done();
    }

    public function testFromModule() {
        var a:Default<TFoo.TBar> = nil;

        #if !static
        asserts.assert( a != null );
        asserts.assert( a.twins != null );
        asserts.assert( a.twins.a != null );
        #end
        asserts.assert( a.twins.a == '' );
        #if !static
        asserts.assert( a.twins.b != null );
        #end
        asserts.assert( a.twins.b == '' );

        return asserts.done();
    }

}

private typedef Def = {
    foo:Foo,
}

private typedef Foo = {
    var a:Int;
    @:optional var b:String;
    var c:Float;
}