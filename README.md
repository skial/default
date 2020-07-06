# Default

> Default values using abstracts.

## Default Values

| Type          | Value     |
| --------      | --------  |
| `Int`         | `0`       |
| `Float`       | `.0`      |
| `Bool`        | `false`   |
| `String`      | `""`      |
| `Array<T>`    | `[]`      |
| `{}`          | `{}`      |

##### Supported Targets

| Php   | Python | JVM  | C#    | Js/Node   | Interp | Neko | HashLink  | Lua   | CPP   |
| -     | -      | -    | -     | -         | -      | -    | -         | -     | -     |
| ✅   | ✅     | ✅  | ✅    | ✅       | ✅     | ✅  | ✅        | ➖   | ➖    |

## Types

### `NIL` or `nil`

To be used instead of `null` when assigning to `Default<T>` values.

### `Default<T>`

```Haxe
@:forward 
abstract Default<T>(T) from T to T {
    // Unsafe access, does not check for nullness.
    function get():T;
    // Replaces `NIL` or `nil` with a valid value at compile time.
    @:from static macro function fromNIL<T>(v:ExprOf<NIL>):ExprOf<Default<T>>;
}
```

#### Conditional Defines

Add `-debug` & `-D default_debug` for further, macro related traces to help w/ debugging.
Add `-D inline_defaults` to `inline` the default values.

### Notes

If using with `tink_json`, you'll need to compile with `-D tink_json_compact_code` for both to work.

