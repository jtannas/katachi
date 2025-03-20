---
sidebar_position: 2
---

# AnyOf

If you're dealing with more variable data, there's `any_of` to allow multiple types.
This is especially useful for optional values, since we treat `nil` just like any other value.

```ruby
value = user.preferred_name
shape = Kt.any_of(String, nil)
Kt.compare(value:, shape:).match? # => true
```

It can also be used to make a key optional in a hash.

```ruby
value = {a: 1}
shape = {a: Integer, b: Kt.any_of(Integer, :$undefined)}
Kt.compare(value:, shape:).match? # => true
```

See the [Hashes](./Hashes.md) document for more information on the special `:$undefined` shape.

## Alternative Syntax

In the documentation, we call `Kt.any_of` as a method, but that's actually just a convenience.

You can also use the `AnyOf` class directly.

It's all up to your personal preference.

```ruby title="Alternative Syntax Examples"
Kt.any_of(String, nil)
Kt::AnyOf.new(String, nil)
Kt::AnyOf[String, nil]
```
