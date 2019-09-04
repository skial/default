package be.types;

class Defaults {

    public static final int:Int = 0;
    public static final float:Float = .0;
    public static final string:String = '';
    public static final bool:Bool = false;
    //public static final array:Array<Any> = [];
    //public static final nullable:Null<Any> = null;
    public static inline function passthrough<T>(v:T):T return v;

}