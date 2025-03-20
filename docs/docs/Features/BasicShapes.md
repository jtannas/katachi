---
sidebar_position: 1
---

# Basic Shapes

The comparison system is built on the power of the Ruby `===` operator.

This gives it the flexibility to match on a wide variety of shapes.

```ruby title="Exact Match"
Kt.compare(value: 1, shape: 1).match? # => true
```

```ruby title="Type Match"
Kt.compare(value: 1, shape: Integer).match? # => true
```

```ruby title="Regex Match"
Kt.compare(value: 'hello', shape: /ell/).match? # => true
```

```ruby title="Proc Match"
Kt.compare(value: 4, shape: ->(v) { v > 3 }).match? # => true

```

```ruby title="Range Match"
Kt.compare(value: 4, shape: 1..5).match? # => true
```
