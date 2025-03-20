# RSpec Integration

When using Rspec, the way it turns question mark methods in to `be_` methods is a perfect fit for our `match?` method.

```ruby title="RSpec converts match? to be_match"
# The following two lines are equivalent
expect(Kt.compare('abc', 'abc').match?).to be true
expect(Kt.compare('abc', 'abc')).to be_match
```

For when you don't want a match, RSpec has a helpful utility for defining the opposite of a matcher.

```ruby title="RSpec defines negated matchers"
RSpec::Matchers.define_negated_matcher :be_mismatch, :be_match
expect(Kt.compare('abc', 123)).to be_mismatch
```

We've also added RSpec matchers to make testing your shapes even easier.

```ruby title="RSpec custom matchers"
require 'katachi/rspec'

expect(Kt.compare('abc', 123)).to have_compare_code(:mismatch)
expect('abc').to have_shape(String)
expect('abc').to have_shape('abc').with_code(:exact_match)
```
