package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class SingleAbstractField {

    public function new() {}

    public function test() {
        var v:Default<Abs> = nil;

        #if !static
        asserts.assert( v != null );
        #end
        asserts.assert( v.a == '' );

        return asserts.done();
    }

}

private abstract Abs(String) {

    public var a(get, set):String;
    private inline function get_a() return this;
    private inline function set_a(v) return this = a;

    public function new(a:String) {
        this = a;
    }

}