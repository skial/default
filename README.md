# Default

> Cross-platform default values using abstract types.

## Notes

- Passing a variable typed `Default<T>` to `Dynamic` will **not** check for nullness.
- A reminder from the Haxe manual about [type nullability](https://haxe.org/manual/types-nullability.html):
    ##### Static Targets
    > Static targets employ their own type system where null is not a valid value for basic types. This is true for the Flash, C++, Java and C# targets.

    ##### Dynamic Targets
    > Dynamic targets are more lenient with their types and allow null values for basic types. This applies to the JavaScript, PHP, Neko and Flash 6-8 targets.
- For Classes, Typesdef Anonymous structures and Enums _(with one exception)_, `Default` will build that type with the values listed below **ONLY IF** assigned `NIL`, not `null`.
- When constructing Enums, Default will attempt to use the first constructor listed. If that constructor has args and one of them is typed the same as the Enum, Default will move onto the next constructor. If none are suitable, an error will be thrown.

## Default Values

| Type | Value |
| -------- | -------- |
| `Int`   | `0`   |
| `Float`   | `.0`   |
| `Bool`   | `false`   |
| `String`   | `""`   |
| `Array<T>`   | `[]`   |
| `{}`   | `{}`   |

## Types

### `NIL`

To be used instead of `null`.

### `Default<T>`

```Haxe
@:forward abstract Default<T>(T) {
    // Unsafe access, does not check for nullness.
    public function get():T;
    // Replaces `NIL` with a valid value at compile time.
    @:from public static macro function fromNIL<T>(v:ExprOf<NIL>):ExprOf<be.types.Default<T>>;
}
```

#### Conditional Defines

Add `-debug` & `-D default_debug` for further, helpful, macro related statements to help debugging.
Add `-D nightly` if working with a nightly build of the Haxe compiler.


