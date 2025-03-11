# frozen_string_literal: true

class CustomMatchesClass
  def self.===(other) = true
end

class CustomNoMatchesClass
  def self.===(other) = false
end

RSpec.describe Katachi::Validator do
  describe ".validate" do
    it_behaves_like(
      "a pure kwargs function",
      method: :validate,
      kwargs_to_outputs: {
        # String
        { value: "foo", shapes: ["foo"] } => <<~RETURN.chomp,
          PASS: Value `"foo"` matched a shape in ["foo"]
          => PASS: Value `"foo"` matched shape `"foo"`
        RETURN
        # { value: "foo", shapes: [/foo/] } => <<~RETURN.chomp,
        #   PASS: Value `"foo"` matched a shape in [/foo/]
        #   => PASS: Value `"foo"` matched shape `/foo/`
        # RETURN
        # { value: "foo", shapes: [:foo] } => <<~RETURN.chomp,
        #   FAIL: Value `"foo"` does not match any of the shapes in [:foo]
        #   => FAIL: Value `"foo"` does not match shape `:foo`
        # RETURN
        # { value: "foo", shapes: ["$foo:bar", /bar/] } => <<~RETURN.chomp,
        #   FAIL: Value `"foo"` does not match any of the shapes in ["$foo:bar", /bar/]
        #   => FAIL: Value `"foo"` does not match shape `/bar/`
        # RETURN
        # { value: "c", shapes: ["c"..."x"] } => <<~RETURN.chomp,
        #   PASS: Value `"c"` matched a shape in ["c"..."x"]
        #   => PASS: Value `"c"` matched shape `"c"..."x"`
        # RETURN
        # { value: "c", shapes: ["d"..."x"] } => <<~RETURN.chomp,
        #   FAIL: Value `"c"` does not match any of the shapes in ["d"..."x"]
        #   => FAIL: Value `"c"` does not match shape `"d"..."x"`
        # RETURN
        # { value: "c", shapes: [1...3, "c", "foo"] } => <<~RETURN.chomp,
        #   PASS: Value `"c"` matched a shape in [1...3, "c", "foo"]
        #   => FAIL: Value `"c"` does not match shape `1...3`
        #   => PASS: Value `"c"` matched shape `"c"`
        #   => FAIL: Value `"c"` does not match shape `"foo"`
        # RETURN
        # { value: "c", shapes: [1...3, :foo, "foo"] } => <<~RETURN.chomp,
        #   FAIL: Value `"c"` does not match any of the shapes in [1...3, :foo, "foo"]
        #   => FAIL: Value `"c"` does not match shape `1...3`
        #   => FAIL: Value `"c"` does not match shape `:foo`
        #   => FAIL: Value `"c"` does not match shape `"foo"`
        # RETURN
        # # Numbers
        # { value: 1, shapes: [1] } => <<~RETURN.chomp,
        #   PASS: Value `1` matched a shape in [1]
        #   => PASS: Value `1` matched shape `1`
        # RETURN
        # { value: 1, shapes: [1...2] } => <<~RETURN.chomp,
        #   PASS: Value `1` matched a shape in [1...2]
        #   => PASS: Value `1` matched shape `1...2`
        # RETURN
        # { value: 1, shapes: [:foo] } => <<~RETURN.chomp,
        #   FAIL: Value `1` does not match any of the shapes in [:foo]
        #   => FAIL: Value `1` does not match shape `:foo`
        # RETURN
        # { value: 1, shapes: ["$foo:bar"] } => <<~RETURN.chomp,
        #   FAIL: Value `1` does not match any of the shapes in ["$foo:bar"]
        # RETURN
        # { value: 1, shapes: [4...7] } => <<~RETURN.chomp,
        #   FAIL: Value `1` does not match any of the shapes in [4...7]
        #   => FAIL: Value `1` does not match shape `4...7`
        # RETURN
        # { value: 1, shapes: ["a"..."d"] } => <<~RETURN.chomp,
        #   FAIL: Value `1` does not match any of the shapes in ["a"..."d"]
        #   => FAIL: Value `1` does not match shape `"a"..."d"`
        # RETURN
        # # Booleans
        # { value: true, shapes: [true] } => <<~RETURN.chomp,
        #   PASS: Value `true` matched a shape in [true]
        #   => PASS: Value `true` matched shape `true`
        # RETURN
        # { value: false, shapes: [false] } => <<~RETURN.chomp,
        #   PASS: Value `false` matched a shape in [false]
        #   => PASS: Value `false` matched shape `false`
        # RETURN
        # { value: true, shapes: [false] } => <<~RETURN.chomp,
        #   FAIL: Value `true` does not match any of the shapes in [false]
        #   => FAIL: Value `true` does not match shape `false`
        # RETURN
        # { value: false, shapes: [true] } => <<~RETURN.chomp,
        #   FAIL: Value `false` does not match any of the shapes in [true]
        #   => FAIL: Value `false` does not match shape `true`
        # RETURN
        # { value: true, shapes: [1] } => <<~RETURN.chomp,
        #   FAIL: Value `true` does not match any of the shapes in [1]
        #   => FAIL: Value `true` does not match shape `1`
        # RETURN
        # { value: true, shapes: [:foo] } => <<~RETURN.chomp,
        #   FAIL: Value `true` does not match any of the shapes in [:foo]
        #   => FAIL: Value `true` does not match shape `:foo`
        # RETURN
        # { value: true, shapes: ["$foo:bar"] } => <<~RETURN.chomp,
        #   FAIL: Value `true` does not match any of the shapes in ["$foo:bar"]
        # RETURN
        # # Nil
        # { value: nil, shapes: [nil] } => <<~RETURN.chomp,
        #   PASS: Value `nil` matched a shape in [nil]
        #   => PASS: Value `nil` matched shape `nil`
        # RETURN
        # { value: nil, shapes: [1] } => <<~RETURN.chomp,
        #   FAIL: Value `nil` does not match any of the shapes in [1]
        #   => FAIL: Value `nil` does not match shape `1`
        # RETURN
        # { value: nil, shapes: [] } => <<~RETURN.chomp,
        #   FAIL: Value `nil` does not match any of the shapes in []
        # RETURN
        # # Simple Arrays
        # { value: [], shapes: [[]] } => <<~RETURN.chomp,
        #   PASS: Array `[]` matched a shape in [[]]
        #   => PASS: Value array is empty so it matches any array shape
        # RETURN
        # { value: [], shapes: [Array] } => <<~RETURN.chomp,
        #   PASS: Array `[]` matched a shape in [Array]
        #   => PASS: Shape `Array` allows all arrays
        # RETURN
        # { value: [1], shapes: [Array] } => <<~RETURN.chomp,
        #   PASS: Array `[1]` matched a shape in [Array]
        #   => PASS: Shape `Array` allows all arrays
        # RETURN
        # { value: [], shapes: [[Integer]] } => <<~RETURN.chomp,
        #   PASS: Array `[]` matched a shape in [[Integer]]
        #   => PASS: Value array is empty so it matches any array shape
        # RETURN
        # { value: [1], shapes: [[Integer]] } => <<~RETURN.chomp,
        #   PASS: Array `[1]` matched a shape in [[Integer]]
        #   => PASS: Value `1` matched a shape in [Integer]
        #   => => PASS: Value `1` matched shape `Integer`
        # RETURN
        # { value: [1, 2, 3], shapes: [[Integer]] } => <<~RETURN.chomp,
        #   PASS: Array `[1, 2, 3]` matched a shape in [[Integer]]
        #   => PASS: Value `1` matched a shape in [Integer]
        #   => => PASS: Value `1` matched shape `Integer`
        #   => PASS: Value `2` matched a shape in [Integer]
        #   => => PASS: Value `2` matched shape `Integer`
        #   => PASS: Value `3` matched a shape in [Integer]
        #   => => PASS: Value `3` matched shape `Integer`
        # RETURN
        # { value: [1, 2, 3, "a"], shapes: [[Integer]] } => <<~RETURN.chomp,
        #   FAIL: Array `[1, 2, 3, "a"]` does not match any of the shapes in [[Integer]]
        #   => PASS: Value `1` matched a shape in [Integer]
        #   => => PASS: Value `1` matched shape `Integer`
        #   => PASS: Value `2` matched a shape in [Integer]
        #   => => PASS: Value `2` matched shape `Integer`
        #   => PASS: Value `3` matched a shape in [Integer]
        #   => => PASS: Value `3` matched shape `Integer`
        #   => FAIL: Value `"a"` does not match any of the shapes in [Integer]
        #   => => FAIL: Value `"a"` does not match shape `Integer`
        # RETURN
        # { value: [1, "a"], shapes: [[Integer], [String]] } => <<~RETURN.chomp,
        #   FAIL: Array `[1, "a"]` does not match any of the shapes in [[Integer], [String]]
        #   => PASS: Value `1` matched a shape in [Integer]
        #   => => PASS: Value `1` matched shape `Integer`
        #   => FAIL: Value `"a"` does not match any of the shapes in [Integer]
        #   => => FAIL: Value `"a"` does not match shape `Integer`
        #   => FAIL: Value `1` does not match any of the shapes in [String]
        #   => => FAIL: Value `1` does not match shape `String`
        #   => PASS: Value `"a"` matched a shape in [String]
        #   => => PASS: Value `"a"` matched shape `String`
        # RETURN
        # { value: [1, "a"], shapes: [[Integer, String]] } => <<~RETURN.chomp,
        #   PASS: Array `[1, "a"]` matched a shape in [[Integer, String]]
        #   => PASS: Value `1` matched a shape in [Integer, String]
        #   => => PASS: Value `1` matched shape `Integer`
        #   => => FAIL: Value `1` does not match shape `String`
        #   => PASS: Value `"a"` matched a shape in [Integer, String]
        #   => => FAIL: Value `"a"` does not match shape `Integer`
        #   => => PASS: Value `"a"` matched shape `String`
        # RETURN
        # { value: [nil], shapes: [[Integer, nil]] } => <<~RETURN.chomp,
        #   PASS: Array `[nil]` matched a shape in [[Integer, nil]]
        #   => PASS: Value `nil` matched a shape in [Integer, nil]
        #   => => FAIL: Value `nil` does not match shape `Integer`
        #   => => PASS: Value `nil` matched shape `nil`
        # RETURN
        # # Nested Arrays
        # { value: [[nil]], shapes: [[Integer, nil]] } => <<~RETURN.chomp,
        #   FAIL: Array `[[nil]]` does not match any of the shapes in [[Integer, nil]]
        #   => FAIL: Array `[nil]` does not match any of the shapes in [Integer, nil]
        #   => => FAIL: Array `[nil]` is not the same class as shape `Integer`
        #   => => FAIL: Array `[nil]` is not the same class as shape `nil`
        # RETURN
        # { value: [[nil]], shapes: [[[nil]]] } => <<~RETURN.chomp,
        #   PASS: Array `[[nil]]` matched a shape in [[[nil]]]
        #   => PASS: Array `[nil]` matched a shape in [[nil]]
        #   => => PASS: Value `nil` matched a shape in [nil]
        #   => => => PASS: Value `nil` matched shape `nil`
        # RETURN
        # { value: [1, ["a"]], shapes: [[Integer, [String]]] } => <<~RETURN.chomp,
        #   PASS: Array `[1, ["a"]]` matched a shape in [[Integer, [String]]]
        #   => PASS: Value `1` matched a shape in [Integer, [String]]
        #   => => PASS: Value `1` matched shape `Integer`
        #   => => FAIL: Value `1` does not match shape `[String]`
        #   => PASS: Array `["a"]` matched a shape in [Integer, [String]]
        #   => => FAIL: Array `["a"]` is not the same class as shape `Integer`
        #   => => PASS: Value `"a"` matched a shape in [String]
        #   => => => PASS: Value `"a"` matched shape `String`
        # RETURN
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

  describe ".validate_string" do
    it "returns a matching result for two identical strings" do
      result = described_class.validate_string(string: "foo", shape: "foo")
      expect(result).to have_attributes(code: :match)
    end

    it "returns a no_match result for two different strings" do
      result = described_class.validate_string(string: "foo", shape: "foo_bar")
      expect(result).to have_attributes(code: :no_match)
    end

    it "returns a matching result for a matching regex" do
      result = described_class.validate_string(string: "foo", shape: /foo/)
      expect(result).to have_attributes(code: :match)
    end

    it "returns a no_match result for an non-matching regex" do
      result = described_class.validate_string(string: "foo", shape: /foo_bar/)
      expect(result).to have_attributes(code: :no_match)
    end

    it "returns a matching result for a matching range" do
      result = described_class.validate_string(string: "f", shape: "a"..."z")
      expect(result).to have_attributes(code: :match)
    end

    it "returns a non-matching result for a non-matching range" do
      result = described_class.validate_string(string: "f", shape: "a"..."e")
      expect(result).to have_attributes(code: :no_match)
    end

    it "returns a no_match result for an incompatible range" do
      result = described_class.validate_string(string: "foo", shape: 1...10)
      expect(result).to have_attributes(code: :no_match)
    end

    it "returns an appropriate code for a directive string" do
      result = described_class.validate_string(string: "foo", shape: "$foo:bar")
      expect(result).to have_attributes(code: :shape_is_a_directive)
    end

    it "returns a no_match code for a compatible shape" do
      result = described_class.validate_string(string: "foo", shape: CustomMatchesClass)
      expect(result).to have_attributes(code: :match)
    end

    it "returns a no_match code for an incompatible shape" do
      result = described_class.validate_string(string: "foo", shape: CustomNoMatchesClass)
      expect(result).to have_attributes(code: :no_match)
    end
  end
end
