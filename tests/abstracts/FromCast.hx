package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class FromCast {

    public function new() {}

    public function test() {
        var a:Default<Abs0> = nil;

        #if !static
        asserts.assert( a != null );
        #end
        asserts.assert( a.toString() == Std.string({a:'', b:0}) );
        asserts.assert( a.a == '' );
        asserts.assert( a.b == 0 );

        return asserts.done();
    }

}

@:forward
private abstract Abs0({a:String, b:Int}) from {a:String, b:Int} {

    public function toString():String {
        return Std.string(this);
    }

}