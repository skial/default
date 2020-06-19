package enums;

import be.types.NIL;
import be.types.Default;

@:asserts
class RecursiveEnum {

    public function new() {}

    public function test() {
        var a:Default<A> = NIL;

        asserts.assert( a != null );
        asserts.assert( a.get().match( Ref(Arg(0, '', .0)) ) );

        return asserts.done();
    }

}

private enum B {
    Arg(a:Int, b:String, c:Float);
}

private enum A {
    Loop(v:A);
    Ref(r:B);
}