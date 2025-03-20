---
sidebar_position: 4
---

# Array Comparison

Arrays are checked to ensure their contents also match the shape.

```ruby title="Simple Array Comparison"
Kt.compare(value: [1], shape: [Integer]).match? # => true
```

Since arrays aren't usually a fixed length, we don't compare the length
of the value and shape arrays.

Instead, we treat the contents of the shape
array like `any_of`.

`[String, Integer]` is effectively shorthand for `[Kt.any_of(String, Integer)]`.

```ruby title="Pseudo-Code of Array Comparison"
array_matches = value.all? do |element|
  shape.any? do |shape_element|
    Kt.compare(value: element, shape: shape_element).match?
  end
end
```

Seeing a few examples is probably the best way to understand how this works.

```ruby title="Sample Array Comparisons"
Kt.compare(value: [1, 2, 3, 4, 5], shape: [Integer]).match? # => true
Kt.compare(value: ['a', 'b', 'c'], shape: [Integer]).match? # => false
Kt.compare(value: [1, 2, 'c'], shape: [Integer]).match? # => false
Kt.compare(value: ['a', 2, 'c', 4], shape: [Integer, String]).match? # => true
```

### Fixed Length Arrays

We said arrays aren't _usually_ a fixed length but it does happen.

For this situation, the Ruby `in` operator is your friend.

Here's how you can check for an array of exactly 5 elements without a lot of typing.

```ruby title="Array length matching using the 'in' operator"
value = [1, 2, 3, 4, 5]
shape = ->(v) { v in ([Integer] * 5) }
Kt.compare(value:, shape:).match? # => true

```

### Specific Values at Specific Indexes

Ruby's `in` works well for when you want to check for specific values at specific indexes.

```ruby title="Array with specific values at specific indexes"
value = [1, 'a', 2]
shape = ->(v) { v in [Integer, String, 2] }
Kt.compare(value:, shape:).match? # => true
```

### Nested Arrays

Checks are recursive, so you can nest arrays as deep as you like.

```ruby title="Nested arrays"
value = [1, [2, [3, 4]]]
shape = [Integer, [Integer, [Integer]]]
Kt.compare(value:, shape:).match? # => true
```
