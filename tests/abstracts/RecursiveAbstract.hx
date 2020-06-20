package abstracts;

import be.types.NIL;
import be.types.Default;

@:asserts
class RecursiveAbstract {

    public function new() {}

    public function test() {
        var a:Default<A> = nil;
        
        return asserts.done();
    }

}

private abstract A({a:B, s:String}) {

    public var a(get, never):B;
    private function get_a():B return this.a;

    public function new(_a:B, _s:String) {
        this = {a:_a, s:_s};
    }

}

private abstract B({b:A}) {

    public var b(get, never):A;
    private inline function get_b() return this.b;

    public function new(_b:A) {
        this = {b:_b};
    }

}