# Katachi

A tool for describing and validating objects as intuitively as possible.

```ruby
Katachi.compare(
    value: {name: 'John', age: 30},
    shape: {name: String, age: Integer}
).match? # => true
```

## Features

### Basic Shape Matching

A comparison system built on the power of the Ruby `===` operator.

```ruby
Kt = Katachi
Kt.compare(value: 'hello', shape: 'hello').match? # => true
Kt.compare(value: 'hello', shape: 'world').match? # => false
Kt.compare(value: 'hello', shape: String).match? # => true
Kt.compare(value: 'hello', shape: /ell/).match? # => true
Kt.compare(value: 4. shape: 1..10).match? # => true
Kt.compare(value: 4, shape: ->(v) { v > 3 }).match? # => true
```

For things like nullable values, there's `any_of` to allow multiple types.

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

If you think there's a shape everyone should have, feel free to open an issue! Or better yet, a PR!

### Array Comparison

Arrays are checked to ensure their contents also match the shape.

```ruby
Kt.compare(value: [1], shape: [Integer]).match? # => true
```

Since arrays aren't usually a fixed length, you don't have to specify
every element in the array -- only their type.

```ruby
Kt.compare(value: [1, 2, 3], shape: [Integer]).match? # => true
```

For mixed arrays, you can allow multiple types without the need for `any_of`.

```ruby
value = [1, 'hello', 1]
shape = [Integer, String]
Kt.compare(value:, shape:).match? # => true
```

If you want to do more complex comparisons, a proc using `in` is a great option.

```ruby
value = [1, 'a', 2]
shape = ->(v) { v in [Integer, String, Integer] }
Kt.compare(value:, shape:).match? # => true
```

Checks are recursive, so you can nest arrays as deep as you like.

```ruby
value = [1, [2, [3, 4]]]
shape = [Integer, [Integer, [Integer]]]
expect(Kt.compare(value:, shape:)).to be_match
```

### Hash Comparison

Hashes are checked to ensure their keys and values match the shape.

```ruby
Kt.compare(value: {a: 1}, shape: {a: Integer}).match? # => true
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

```ruby
value = {a: 1, b: 2, "foo" => "bar"}
shape = {a: Integer, Object => Object}
Kt.compare(value:, shape:).match? # => true
```

We've made sure that if you go through the trouble of specifying a key, it will override more generic matches.

```ruby
value = {a: 1, b: 2}
shape = {a: 10, Object => Object}
Kt.compare(value:, shape:).match? # => false
```

For making keys optional, we provide a special `:$undefined` shape.

```ruby
value = {a: 1}
shape = {a: Integer, b: Kt.any_of(Integer, :$undefined)}
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

We've added RSpec matchers to make testing your shapes even easier.

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
shape = { a: Integer, foo: String })
result = Kt.compare(value:, shape:)
result.match? # => false
result.code # => :hash_is_mismatch
result.child_results # contains the recursive results of interior comparisons
result.to_s == <<~RESULT
:hash_is_mismatch <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String})
  :hash_has_no_missing_keys <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String})
    :hash_key_present <-- compare(value: :a, shape: :a)
    :hash_key_present <-- compare(value: :foo, shape: :foo)
  :hash_has_no_extra_keys <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String})
    :hash_key_allowed <-- compare(value: :a, shape: :a)
    :hash_key_allowed <-- compare(value: :foo, shape: :foo)
  :hash_values_are_mismatch <-- compare(value: {a: 1, foo: :bar}, shape: {a: Integer, foo: String})
    :kv_specific_match <-- compare(value: {a: 1}, shape: {a: Integer})
      :match <-- compare(value: 1, shape: Integer)
    :kv_specific_mismatch <-- compare(value: {foo: :bar}, shape: {foo: String})
      :mismatch <-- compare(value: :bar, shape: String)"
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
- [ ] Recursive shape definitions (e.g. `:$user => {name: String, spouse: Kt.any_of(:$user, nil)}`)
- [ ] `katachi-rspec-api` for testing+documenting APIs in a way inspired [RSwag](https://github.com/rswag/rswag)

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
$ bundle add katachi
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
$ gem install katachi
```

## Development and Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for information on how to contribute to Katachi.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
