# frozen_string_literal: true

RSpec.describe Katachi::Validator do
  describe ".validate" do
    it_behaves_like(
      "a pure kwargs function",
      method: :validate,
      kwargs_to_outputs: {
        # String
        { value: "foo", shapes: ["foo"] } => <<~RETURN.chomp,
          PASS: Value `"foo"` matched a shape
          => PASS: Value `"foo"` matched shape `"foo"`
        RETURN
        { value: "foo", shapes: [/foo/] } => <<~RETURN.chomp,
          PASS: Value `"foo"` matched a shape
          => PASS: Value `"foo"` matched shape `/foo/`
        RETURN
        { value: "foo", shapes: [:foo] } => <<~RETURN.chomp,
          FAIL: Value `"foo"` does not match any of the shapes
          => FAIL: Value `"foo"` does not match shape `:foo`
        RETURN
        { value: "foo", shapes: ["$foo:bar", /bar/] } => <<~RETURN.chomp,
          FAIL: Value `"foo"` does not match any of the shapes
          => FAIL: Value `"foo"` does not match shape `/bar/`
        RETURN
        { value: "c", shapes: ["c"..."x"] } => <<~RETURN.chomp,
          PASS: Value `"c"` matched a shape
          => PASS: Value `"c"` matched shape `"c"..."x"`
        RETURN
        { value: "c", shapes: ["d"..."x"] } => <<~RETURN.chomp,
          FAIL: Value `"c"` does not match any of the shapes
          => FAIL: Value `"c"` does not match shape `"d"..."x"`
        RETURN
        { value: "c", shapes: [1...3, "c", "foo"] } => <<~RETURN.chomp,
          PASS: Value `"c"` matched a shape
          => FAIL: Value `"c"` does not match shape `1...3`
          => PASS: Value `"c"` matched shape `"c"`
          => FAIL: Value `"c"` does not match shape `"foo"`
        RETURN
        { value: "c", shapes: [1...3, :foo, "foo"] } => <<~RETURN.chomp,
          FAIL: Value `"c"` does not match any of the shapes
          => FAIL: Value `"c"` does not match shape `1...3`
          => FAIL: Value `"c"` does not match shape `:foo`
          => FAIL: Value `"c"` does not match shape `"foo"`
        RETURN
        # Numbers
        { value: 1, shapes: [1] } => <<~RETURN.chomp,
          PASS: Value `1` matched a shape
          => PASS: Value `1` matched shape `1`
        RETURN
        { value: 1, shapes: [1...2] } => <<~RETURN.chomp,
          PASS: Value `1` matched a shape
          => PASS: Value `1` matched shape `1...2`
        RETURN
        { value: 1, shapes: [:foo] } => <<~RETURN.chomp,
          FAIL: Value `1` does not match any of the shapes
          => FAIL: Value `1` does not match shape `:foo`
        RETURN
        { value: 1, shapes: ["$foo:bar"] } => <<~RETURN.chomp,
          FAIL: Value `1` does not match any of the shapes
        RETURN
        { value: 1, shapes: [4...7] } => <<~RETURN.chomp,
          FAIL: Value `1` does not match any of the shapes
          => FAIL: Value `1` does not match shape `4...7`
        RETURN
        { value: 1, shapes: ["a"..."d"] } => <<~RETURN.chomp,
          FAIL: Value `1` does not match any of the shapes
          => FAIL: Value `1` does not match shape `"a"..."d"`
        RETURN
        # Booleans
        { value: true, shapes: [true] } => <<~RETURN.chomp,
          PASS: Value `true` matched a shape
          => PASS: Value `true` matched shape `true`
        RETURN
        { value: false, shapes: [false] } => <<~RETURN.chomp,
          PASS: Value `false` matched a shape
          => PASS: Value `false` matched shape `false`
        RETURN
        { value: true, shapes: [false] } => <<~RETURN.chomp,
          FAIL: Value `true` does not match any of the shapes
          => FAIL: Value `true` does not match shape `false`
        RETURN
        { value: false, shapes: [true] } => <<~RETURN.chomp,
          FAIL: Value `false` does not match any of the shapes
          => FAIL: Value `false` does not match shape `true`
        RETURN
        { value: true, shapes: [1] } => <<~RETURN.chomp,
          FAIL: Value `true` does not match any of the shapes
          => FAIL: Value `true` does not match shape `1`
        RETURN
        { value: true, shapes: [:foo] } => <<~RETURN.chomp,
          FAIL: Value `true` does not match any of the shapes
          => FAIL: Value `true` does not match shape `:foo`
        RETURN
        { value: true, shapes: ["$foo:bar"] } => <<~RETURN.chomp,
          FAIL: Value `true` does not match any of the shapes
        RETURN
        # Nil
        { value: nil, shapes: [nil] } => <<~RETURN.chomp,
          PASS: Value `nil` matched a shape
          => PASS: Value `nil` matched shape `nil`
        RETURN
        { value: nil, shapes: [1] } => <<~RETURN.chomp,
          FAIL: Value `nil` does not match any of the shapes
          => FAIL: Value `nil` does not match shape `1`
        RETURN
        { value: nil, shapes: [] } => <<~RETURN.chomp,
          FAIL: Value `nil` does not match any of the shapes
        RETURN
        # # Simple Arrays
        # { value: [], shapes: [[]] } => [],
        # { value: [], shapes: [Array] } => [],
        # { value: [1], shapes: [Array] } => [],
        # { value: [], shapes: [[Integer]] } => [],
        # { value: [1], shapes: [[Integer]] } => [],
        # { value: [1, 2, 3], shapes: [[Integer]] } => [],
        # { value: [1, 2, 3, "a"], shapes: [[Integer]] } => false,
        # { value: [1, "a"], shapes: [[Integer, String]] } => [],
        # { value: [nil], shapes: [[Integer, nil]] } => [],
        # # Nested Arrays
        # { value: [[nil]], shapes: [[Integer, nil]] } => false,
        # { value: [[nil]], shapes: [[[nil]]] } => [],
        # { value: [1, 2, ["a"]], shapes: [[Integer, [String]]] } => [],
        # { value: [
        #     %w[First Last Age],
        #     ["John", "Doe", 42],
        #     ["Jane", "Doris", 59]
        #   ],
        #   shapes: [[[String, Integer]]] } => [],
        # # Hashes
        # { value: { a: 1 }, shapes: [Hash] } => [],
        # { value: { a: {} }, shapes: [{ a: [Hash] }] } => [],
        # { value: { a: nil }, shapes: [{ a: [Integer, nil] }] } => [],
        # {
        #   value: { first: "John", last: "Doe", dob: Time.now },
        #   shapes: [{ first: [String], last: [String], dob: [Time] }],
        # } => [],
        # {
        #   value: { first: "John", last: "Doe", age: 42 },
        #   shapes: [{ first: [String], last: [String], dob: [Time] }],
        # } => false,
        # {
        #   value: {
        #     first: "John",
        #     last: "Doe",
        #     dob: Time.now,
        #     spouse: { first: "Jane", last: "Doe", dob: Time.now },
        #   },
        #   shapes: [{
        #     first: [String],
        #     last: [String],
        #     dob: [Time],
        #     spouse: [nil, { first: [String], last: [String], dob: [Time] }],
        #   }],
        # } => [],
        # # Hashes with missing keys
        # { value: { a: {} }, shapes: [{ a: [Hash], b: [Integer] }] } => false,
        # { value: { a: 1 }, shapes: [{ a: [Integer], b: [Integer, :undefined] }] } => [],
        # # Hashes with extra keys
        # { value: { a: 1, b: 2 }, shapes: [{ a: [Integer] }] } => false,
        # { value: { a: 1, b: 2 }, shapes: [{ a: [Integer], "$extra_keys" => true }] } => [],
      }
    )
  end
end
