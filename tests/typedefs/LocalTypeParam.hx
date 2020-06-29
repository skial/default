package typedefs;

import be.types.NIL;
import be.types.Default;

@:asserts
class LocalTypeParam {

    public function new() {}

    public function test() {
        var a:Default<Foo> = nil;
        #if !static
        asserts.assert( a != null );
        #end
        /**
            Why isnt this inlined into `assert(_)`?
            It causes the compiler to hang if it is. I expect
            one of tink_* libraries gets stuck trying to print/type
            the expression.
        **/
        var check:Bool = a.make != null;
        asserts.assert( check );

        return asserts.done();
    }

}

private typedef Foo = {
    dynamic function make<T>(v:T):Foo;
}