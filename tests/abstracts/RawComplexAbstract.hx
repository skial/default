package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class RawComplexAbstract {

    public function new() {}

    public function test() {
        var v:Default<Abs> = nil;

        #if !static
        asserts.assert( v != null );
        #end
        asserts.assert( v.a == '' );
        asserts.assert( v.b == false );

        return asserts.done();
    }

}

private abstract Abs({foo:String, bar:Bool}) {

    public var a(get, never):String;
    private inline function get_a() return this.foo;
    public var b(get, never):Bool;
    private inline function get_b() return this.bar;

}