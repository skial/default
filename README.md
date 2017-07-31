# Default

> Cross-platform default values using abstract types.

## Types

### `NIL`

Meant as a replacement for `null`.

### `Default<T>`

```Haxe
@:forward abstract Default<T>(T) {
    // Unsafe access, does not check for nullness.
    public function get():T;
    // All the following check for nullness.
    @:to public function asInt():Int;   // Defaults to `0`
    @:to public function asFloat():Float;   // Defaults to `.0`
    @:to public function asArray<A>():Array<A>; // Default to `[]`
    @:to public static function asObject(v:Default<{}>):{}; // Defaults to `{}`
    @:to public static function asString<T:String>(v:Default<T>):String;    // Defaults to `''`
    @:to public static function asStringyArray<T>(v:Default<Array<T>>):String; // Correctly stringifys an Array
    // Replaces `NIL` with a valid value at compile time.
    @:from public static macro function fromNIL<T>(v:ExprOf<NIL>):ExprOf<be.types.Default<T>>;
}
```

