package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class FromCastField {

    public function new() {}

    public function test() {
        var a:Default<Abs0> = NIL;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a.toString() == Std.string(0) );

        return asserts.done();
    }

}

@:forward
private abstract Abs0(String) {

    public function toString():String {
        return this;
    }

    @:from public static function fromInt(v:Int) {
        return cast Std.string(v);
    }

    @:from public static function fromFloat(v:Float) {
        return cast Std.string(v);
    }

}