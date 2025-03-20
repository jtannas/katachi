---
sidebar_position: 5
---

# Hash Comparison

Hashes are checked to ensure their keys and values match the shape.

```ruby
value = {a: 1}
shape = {a: Integer}
Kt.compare(value:, shape:).match? # => true
```

By default, no extra or missing hash keys are allowed.

```ruby title="Extra and Missing Keys Are Not Allowed"
# This will fail because `:b` is not in the shape
value = {a: 1, b: 2}
shape = {a: Integer}
Kt.compare(value:, shape:).match? # => false

# This will fail because `:b` is missing from the value
value = {a: 1}
shape = {a: Integer, b: String}
Kt.compare(value:, shape:).match? # => false
```

## Extra Keys

If you want to allow extra keys, no special syntax is needed.
Ruby comes to the rescue!

Ruby accepts more than just strings and symbols as hash keys.

We take advantage of this by applying the same comparison logic to the keys as we do to the values.

```ruby title="Allowing Extra Keys"
value = {a: 1, b: 2, c: 3}
shape = {a: Integer, Symbol => Integer}
Kt.compare(value:, shape:).match? # => true
```

We've made sure that if you go through the trouble of describing an exact key, it will override more "generic" matches.

```ruby title="Exact Keys Override Generic Matches"
value = {a: 'a', b: 'b', c: 'c'}
shape = {a: 'foo', Symbol => String}
Kt.compare(value:, shape:).match? # => false
```

:::info

We consider a shape that defines a [case-equality operator (`===`)](https://thoughtbot.com/blog/case-equality-operator-in-ruby) to be a generic matcher.

:::

## Key Shapes

All the key matching logic is the same as for values, you can use any shape you like for the keys.

```ruby title="Using a UUID as a Key"
value = { "123e4567-e89b-12d3-a456-426614174000" => "My Id" }
shape = { :$uuid => String}
Kt.compare(value:, shape:).match? # => true
```

:::caution

While you _can_ use a shape for a key, for simplicity it's usually best to stick to simple shapes.

:::

## Optional Keys

For making keys optional, we provide a special `:$undefined` shape.

```ruby title="Making a Key Optional"
value = {a: 1}
shape = {a: Integer, b: Kt.any_of(Integer, :$undefined)}
Kt.compare(value:, shape:).match? # => true
```

This can also be used to disallow a key even when allowing extra keys.

```ruby title="Disallowing a key"
value = {a: 1, b: 2, secret: 'shh'}
shape = {Symbol => Object, secret: :$undefined}
Kt.compare(value:, shape:).match? # => false
```

## Nested Hashes

As with arrays, hashes can be nested as deep as you like.

```ruby
value = {a: {b: {c: 1}}}
shape = {a: {b: {c: Integer}}}
Kt.compare(value:, shape:).match? # => true
```

:::info

If you're looking for a more in-depth overview of how hash comparison works, check out the [Hash Comparison Design Document](../Contributing/HashComparisonDesign.md) document.
