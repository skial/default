package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class FromCastFieldComplex {

    public function new() {}

    public function test() {
        var a:Default<Abs0> = nil;

        asserts.assert( a != null );
        asserts.assert( a.toString() == Std.string({a:'', b:0}) );
        asserts.assert( a.a == '' );
        asserts.assert( a.b == 0 );

        return asserts.done();
    }

}

@:forward
private abstract Abs0({a:String, b:Int}) {

    public function toString():String {
        return Std.string(this);
    }

    @:from public static function fromObj(v:{a:String, b:Int}) {
        return cast v;
    }

}