package be.types._default;

/*class Defaults {

    public static #if inline_defaults inline #end final int:Int = 0;
    public static #if inline_defaults inline #end final float:Float = .0;
    public static #if inline_defaults inline #end final string:String = '';
    public static #if inline_defaults inline #end final bool:Bool = false;
    //public static final array:Array<Any> = [];
    //public static final nullable:Null<Any> = null;
    public static inline function passthrough<T>(v:T):T return v;

}*/

abstract Defaults<T>(T) to T {
    private inline function new(v) this = v;
    @:from public static inline function fromInt(v:Int):Defaults<Int> return new Defaults( int );
    @:from public static inline function fromFloat(v:Float):Defaults<Float> return new Defaults( float );
    @:from public static inline function fromString(v:String):Defaults<String> return new Defaults( string );
    @:from public static inline function fromBool(v:Bool):Defaults<Bool> return new Defaults( bool );

    public static #if inline_defaults inline #end final int:Int = 0;
    public static #if inline_defaults inline #end final float:Float = .0;
    public static #if inline_defaults inline #end final string:String = '';
    public static #if inline_defaults inline #end final bool:Bool = false;
    //public static final array:Array<Any> = [];
    //public static final nullable:Null<Any> = null;
    public static inline function passthrough<T>(v:T):T return v;
}