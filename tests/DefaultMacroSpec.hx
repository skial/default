package ;

import utest.Assert;
import haxe.macro.Type;
import haxe.macro.Expr;
import be.types.Default;
import haxe.macro.Context;

using tink.CoreApi;
#if (macro || eval)
using tink.MacroApi;
#end

@:keep class DefaultMacroSpec {

    public function new() {

    }

    public function testTDynamic() {
        var e = genTDynamic();
        Assert.equals( '', e.twins.a );
        Assert.equals( '', e.twins.b );
    }

    public static macro function genTDynamic():Expr {
        var type =  Context.getType('TFoo.TBar');
        var result = @:privateAccess Default.typeToValue( TDynamic(type) );
        //trace( result.toString() );
        return result;
    }

    /*public function testTDynamic_null() {
        var e = genTDynamic_null();
        Assert.equals( '', e.twins.a );
        Assert.equals( '', e.twins.b );
    }

    public static macro function genTDynamic_null():Expr {
        var type =  Context.getType('TFoo.TBar');
        var result = @:privateAccess Default.typeToValue( TDynamic(null) );
        //trace( result.toString() );
        return result;
    }*/

}