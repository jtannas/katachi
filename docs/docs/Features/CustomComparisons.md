---
sidebar_position: 6
---

# Custom Comparisons

Need something more complex?

Just add a `kt_compare` method to the object you'd like to compare with.

As long as it returns a `Katachi::Result`, you're good to go!

```ruby title="Example of a custom comparison method"
# This example checks if a customer can ride a rollercoaster based on
# their age, height, and whether they have a parent present.
# Expected value object should have: age, height, and has_parent properties
# The result will contain child results for each of those properties.
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

Kt.compare(value: customer, shape: CanRideThisRollerCoaster).match?
```
