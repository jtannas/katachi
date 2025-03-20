---
sidebar_position: 3
---

# Shape Library

## Predefined Shapes

We provide some common shapes that can be accessed by `:${name}`.

```ruby title="Showcasing the UUID Shape"
Kt.compare(
    value: "123e4567-e89b-12d3-a456-426614174000",
    shape: :$uuid
).match? # => true
```

:::info

The `:$` prefix is inspired by Ruby's `$` usage for global variables.

Think of it as a global variable for shapes, but without the ick of actual global variables.

:::

## Custom Shapes

You can also add your own shapes to fit your needs.

```ruby
Kt.add_shape(:$even, ->(v) { v.even? })
Kt.compare(value: 4, shape: :$even).match? # => true
```

The full list of included shapes can be found in the [predefined_shapes.rb](https://github.com/jtannas/katachi/blob/main/lib/katachi/predefined_shapes.rb) file.

If you think there's a shape everyone should have, feel free to open an issue! Or better yet, a PR!
