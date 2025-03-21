---
sidebar_position: 7
---

# Diagnostics

All comparisons return a `Katachi::Result` object that contains detailed information about the comparison.

```ruby title="Sample Diagnostics from the Katachi::Result object"
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
