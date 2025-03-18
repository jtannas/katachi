![Gem Version](https://img.shields.io/gem/v/katachi)

# Katachi

A tool for describing and validating objects as intuitively as possible.

```ruby
Katachi.compare(
    value: {name: 'John', age: 30},
    shape: {name: String, age: Integer}
).match? # => true
```

## What's with the name?

> The word “katachi” is a composite of “kata” (pattern) and “chi” (magical power), thus it includes meanings such as “complete form” or “form telling an attractive story.” It can reveal the relationship between shape, function and meaning.
>
> https://symmetry-us.com/about_the_site/what-is-katachi/

This tool is all about defining the shape of your data. The usual words of schema, definition, or validator all felt too formal. Since Ruby originated in Japan, I looked up the Japanese word for shape. It came back as 形 (katachi), and the above quote was the first thing I saw when checking for prior usage. It felt like a perfect fit.

## Features

### Basic Shape Matching

A comparison system built on the power of the Ruby `===` operator.

```ruby
Kt = Katachi
Kt.compare(value: 'hello', shape: 'hello').match? # => true
Kt.compare(value: 'hello', shape: 'world').match? # => false
Kt.compare(value: 'hello', shape: String).match? # => true
Kt.compare(value: 'hello', shape: /ell/).match? # => true
Kt.compare(value: 4, shape: 1..10).match? # => true
Kt.compare(value: 4, shape: ->(v) { v > 3 }).match? # => true
```

If you're dealing with more variable data, there's`any_of` to allow multiple types.
This is especially useful for optional values, since we treat `nil` just like any other value.

```ruby
value = user.preferred_name
shape = Kt.any_of(String, nil)
Kt.compare(value:, shape:).match? # => true
```

### An Easy-To-Use Shape Library

We provide some common shapes that can be accessed by `:${name}`.

```ruby
Kt.compare(
    value: "123e4567-e89b-12d3-a456-426614174000",
    shape: :$uuid
).match? # => true
```

You can also add your own shapes to fit your needs.

```ruby
Kt.add_shape(:$even, ->(v) { v.even? })
Kt.compare(value: 4, shape: :$even).match? # => true
```

The full list of included shapes can be found in the [predefined_shapes.rb](./lib/katachi/predefined_shapes.rb) file.
If you think there's a shape everyone should have, feel free to open an issue! Or better yet, a PR!

### Array Comparison

Arrays are checked to ensure their contents also match the shape.

```ruby
Kt.compare(value: [1], shape: [Integer]).match? # => true
```

Since arrays aren't usually a fixed length, we don't compare the length
of the value and shape arrays. Instead, we treat the contents of the shape
array like `any_of`.
`[String, Integer]` is effectively shorthand for `[Kt.any_of(String, Integer)]`.

```ruby
# pseudo-code for how arrays are compared
array_matches = value.all? do |element|
  shape.any? do |shape_element|
    Kt.compare(value: element, shape: shape_element).match?
  end
end
```

Seeing a few examples is probably the best way to understand how this works.

```ruby
Kt.compare(value: [1, 2, 3, 4, 5], shape: [Integer]).match? # => true
Kt.compare(value: ['a', 'b', 'c'], shape: [Integer]).match? # => false
Kt.compare(value: [1, 2, 'c'], shape: [Integer]).match? # => false
Kt.compare(value: ['a', 2, 'c', 4], shape: [Integer, String]).match? # => true
```

We said arrays aren't _usually_ a fixed length but it does happen.

For this situation, the Ruby `in` operator is your friend.

Here's how you can check for an array of exactly 5 elements without a lot of typing.

```ruby
value = [1, 2, 3, 4, 5]
shape = ->(v) { v in ([Integer] * 5) }
Kt.compare(value:, shape:).match? # => true
```

It also works for when you want to check for specific values at specific indexes.

```ruby
value = [1, 'a', 2]
shape = ->(v) { v in [Integer, String, Integer] }
Kt.compare(value:, shape:).match? # => true
```

Checks are recursive, so you can nest arrays as deep as you like.

```ruby
value = [1, [2, [3, 4]]]
shape = [Integer, [Integer, [Integer]]]
Kt.compare(value:, shape:).match? # => true
```

### Hash Comparison

Hashes are checked to ensure their keys and values match the shape.

```ruby
value = {a: 1}
shape = {a: Integer}
Kt.compare(value:, shape:).match? # => true
```

By default, no extra or missing hash keys are allowed.

```ruby
# This will fail because `:b` is not in the shape
value = {a: 1, b: 2}
shape = {a: Integer}
Kt.compare(value:, shape:).match? # => false

# This will fail because `:b` is missing from the value
value = {a: 1}
shape = {a: Integer, b: String}
Kt.compare(value:, shape:).match? # => false
```

If you want to allow extra keys, no special syntax is needed.
Ruby comes to the rescue!
Ruby accepts more than just strings and symbols as hash keys.
We take advantage of this by applying the same comparison logic to the keys as we do to the values.

```ruby
value = {a: 1, b: 2, c: 3}
shape = {a: Integer, Symbol => Integer}
Kt.compare(value:, shape:).match? # => true
```

This means you can use any shape you like for the keys, though it's usually best to stick to simple shapes.

```ruby
value = { "123e4567-e89b-12d3-a456-426614174000" => "My Id" }
shape = { :$uuid => String}
Kt.compare(value:, shape:).match? # => true
```

We've made sure that if you go through the trouble of describing an exact key, it will override more generic matches.
We consider an exact key to be one that doesn't contain a Class, a Range, a Proc, or a Regexp.

```ruby
value = {a: 'a', b: 'b', c: 'c'}
shape = {a: 'foo', Symbol => String}
Kt.compare(value:, shape:).match? # => false
```

For making keys optional, we provide a special `:$undefined` shape.

```ruby
value = {a: 1}
shape = {a: Integer, b: Kt.any_of(Integer, :$undefined)}
Kt.compare(value:, shape:).match? # => true
```

As with arrays, hashes can be nested as deep as you like.

```ruby
value = {a: {b: {c: 1}}}
shape = {a: {b: {c: Integer}}}
Kt.compare(value:, shape:).match? # => true
```

### Custom Comparisons

Need something more complex? Just add a `kt_compare` class method to whatever you'd like to compare.
As long as it returns a `Katachi::Result`, you're good to go!

```ruby
class CanRideThisRollerCoaster
  def self.kt_compare(value:)
    age_check = Kt.compare(value: value.age, shape: 14..)
    height_check = Kt.compare(value: value.height, shape: 42..123)
    has_parent_check = Kt.compare(value: value.has_parent, shape: true)
    is_allowed = height_check.match? && (age_check.match? || has_parent_check.match?)
    Kt::Result.new(
      value:,
      shape: self,
      code: is_allowed ? :match : :mismatch,
      child_results: {age_check:, height_check:, has_parent_check:}
    )
  end
end
```

### RSpec Integration

When using Rspec, the way it turns question mark methods in to `be_` methods is a perfect fit for our `match?` method.

```ruby
# The following two lines are equivalent
expect(Kt.compare('abc', 'abc').match?).to be true
expect(Kt.compare('abc', 'abc')).to be_match
```

For when you don't want a match, RSpec has a helpful utility for defining the opposite of a matcher.

```ruby
RSpec::Matchers.define_negated_matcher :be_mismatch, :be_match
expect(Kt.compare('abc', 123)).to be_mismatch
```

We've also added RSpec matchers to make testing your shapes even easier.

```ruby
require 'katachi/rspec'

expect(Kt.compare('abc', 123)).to have_compare_code(:mismatch)
expect('abc').to have_shape(String)
expect('abc').to have_shape('abc').with_code(:exact_match)
```

### Detailed Diagnostics

All comparisons return a `Katachi::Result` object that contains detailed information about the comparison.

```ruby
value = {a: 1, foo: :bar}
shape = { a: Integer, foo: String }
result = Kt.compare(value:, shape:)
result.match? # => false
result.code # => :hash_is_mismatch
result.child_results # contains the recursive results of interior comparisons
result.to_s == <<~RESULT.chomp
  :hash_is_mismatch <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String})
    :hash_has_no_missing_keys <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String}); child_label: :$required_keys
      :hash_key_exact_match <-- compare(value: :a, shape: :a); child_label: :a
      :hash_key_exact_match <-- compare(value: :foo, shape: :foo); child_label: :foo
    :hash_has_no_extra_keys <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String}); child_label: :$extra_keys
      :hash_key_exactly_allowed <-- compare(value: :a, shape: :a); child_label: :a
      :hash_key_exactly_allowed <-- compare(value: :foo, shape: :foo); child_label: :foo
    :hash_values_are_mismatch <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String}); child_label: :$values
      :kv_specific_match <-- compare(value: {a: 1}, shape: {a: Integer}); child_label: [:a, 1]
        :match <-- compare(value: 1, shape: Integer); child_label: Integer
      :kv_specific_mismatch <-- compare(value: {foo: :bar}, shape: {foo: String}); child_label: [:foo, :bar]
        :mismatch <-- compare(value: :bar, shape: String); child_label: String
RESULT
```

## Future Features Under Consideration

- [ ] More shapes (e.g. `:$email`, `:$url`, `:$iso_8601`)
- [ ] More "matching modifiers" (e.g. `all_of`, `one_of`, `none_of`)
- [ ] Docusaurus github pages for documentation
- [ ] More output formats (e.g. `to_json`, `to_hash`, etc...)
- [ ] Custom shape codes (e.g. `:email_is_invalid`)
- [ ] Minitest integration
- [ ] Rails integration (e.g. `validates_shape_of`)
- [ ] Shape-to-TypeScript conversion
- [ ] Shape-to-Zod conversion
- [ ] Shape-to-OpenAPI conversion
- [ ] `katachi-rspec-api` for testing+documenting APIs in a way inspired by [RSwag](https://github.com/rswag/rswag)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add katachi
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
$ gem install katachi
```

## Inspiration

This is inspired by my experiences testing using [RSwag](https://github.com/rswag/rswag) and from my small part in helping maintain it. I wasn't happy with how often I had to look up the OpenAPI spec to be able to follow it.

A lot of this came down to OpenAPI itself being complex and making significant changes over the years (e.g. `x-nullable: true` → `nullable: true` → `type: ["string", "null"]`). A bigger part is they're limited to valid JSON, so they have very few tools to work with.

I started wondering if I could tweak RSwag to smooth over some of these rough edges. Is there a way to make it easier to write and harder to mess up?

It started as consolidating a few helper functions together, before a bigger question hit me:

**“What if I ditched writing OpenAPI entirely?”**

Rather than drag all of their maintainers and users along with my crackpot schemes, I decided it was time to set off on a new project: `Katachi`

## Development and Contributing

See [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for information on how to contribute to Katachi.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
