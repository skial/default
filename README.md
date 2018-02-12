# Default

> Cross-platform default values using abstract types.

## Notes

Passing a variable typed `Default<T>` to `Dynamic` will **not** check for nullness.

## Types

### `NIL`

Meant as a replacement for `null`.

### `Default<T>`

```Haxe
@:forward abstract Default<T>(T) {
    // Unsafe access, does not check for nullness.
    public function get():T;
    // Replaces `NIL` with a valid value at compile time.
    @:from public static macro function fromNIL<T>(v:ExprOf<NIL>):ExprOf<be.types.Default<T>>;
}
```

#### Default Values

| Type | Value |
| -------- | -------- |
| `Int`   | `0`   |
| `Float`   | `.0`   |
| `Bool`   | `false`   |
| `String`   | `""`   |
| `Array<T>`   | `[]`   |
| `{}`   | `{}`   |

For Classes, Typesdefs Anonymous structures and Enums _(with one exception)_, `Default` will build that type with the values listed above **ONLY IF** assigned `NIL`, not `null`.

When constructing Enums, Default will attempt to use the first constructor listed. If that constructor has args and one of them is typed the same as the Enum, Default will move onto the next constructor. If none are suitable, an error will be thrown.

#### Conditional Defines

Add `-D default_debug` for further, useful, macro related errors to help debugging.
Add `-D nightly` if working with a nightly build of the Haxe compiler.


