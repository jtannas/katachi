# frozen_string_literal: true

# Class defined to always return true when used for match checking
class CustomMatchesClass
  def self.===(_other) = true
end

# Class defined to always return false when used for match checking
class CustomNoMatchesClass
  def self.===(_other) = false
end

RSpec.describe Katachi::Validator do
  describe ".validate_scalar" do
    it "rejects checking an array" do
      expect do
        described_class.validate_scalar(value: [], shape: 1)
      end.to raise_error(ArgumentError, "checked value cannot be an array")
    end

    it "rejects checking a hash" do
      expect do
        described_class.validate_scalar(value: {}, shape: 1)
      end.to raise_error(ArgumentError, "checked value cannot be a hash")
    end

    it "matches for two identical numbers" do
      result = described_class.validate_scalar(value: 1, shape: 1)
      expect(result).to have_attributes(code: :match)
    end

    it "matches for two instances of nil" do
      result = described_class.validate_scalar(value: nil, shape: nil)
      expect(result).to have_attributes(code: :match)
    end

    it "matches for two identical strings" do
      result = described_class.validate_scalar(value: "foo", shape: "foo")
      expect(result).to have_attributes(code: :match)
    end

    it "is not a match for two different strings" do
      result = described_class.validate_scalar(value: "foo", shape: "foo_bar")
      expect(result).to have_attributes(code: :no_match)
    end

    it "matches for a matching regex" do
      result = described_class.validate_scalar(value: "foo", shape: /foo/)
      expect(result).to have_attributes(code: :match)
    end

    it "is not a match for an non-matching regex" do
      result = described_class.validate_scalar(value: "foo", shape: /foo_bar/)
      expect(result).to have_attributes(code: :no_match)
    end

    it "matches for a matching range" do
      result = described_class.validate_scalar(value: "f", shape: "a"..."z")
      expect(result).to have_attributes(code: :match)
    end

    it "returns a non-matching result for a non-matching range" do
      result = described_class.validate_scalar(value: "f", shape: "a"..."e")
      expect(result).to have_attributes(code: :no_match)
    end

    it "is not a match for an incompatible range" do
      result = described_class.validate_scalar(value: "foo", shape: 1...10)
      expect(result).to have_attributes(code: :no_match)
    end

    it "returns an appropriate code for a directive string" do
      result = described_class.validate_scalar(value: "foo", shape: "$foo:bar")
      expect(result).to have_attributes(code: :shape_is_a_directive)
    end

    it "is a match for a compatible class" do
      result = described_class.validate_scalar(value: "foo", shape: CustomMatchesClass)
      expect(result).to have_attributes(code: :match)
    end

    it "is not a match for an incompatible class" do
      result = described_class.validate_scalar(value: "foo", shape: CustomNoMatchesClass)
      expect(result).to have_attributes(code: :no_match)
    end
  end

  describe ".validate_array" do
    it "rejects checking a non-array value" do
      expect do
        described_class.validate_array(value: 1, shape: [])
      end.to raise_error(ArgumentError, "checked value must be an array")
    end

    it "returns an appropriate code for a directive shape" do
      result = described_class.validate_array(value: [], shape: "$foo:bar")
      expect(result).to have_attributes(code: :shape_is_a_directive, child_codes: nil)
    end

    it "returns a class mismatch result for a non-Array shape" do
      result = described_class.validate_array(value: [], shape: 1)
      expect(result).to have_attributes(code: :class_mismatch, child_codes: nil)
    end

    it "matches for an empty array" do
      result = described_class.validate_array(value: [], shape: [Integer])
      expect(result).to have_attributes(code: :match_due_to_empty_array, child_codes: nil)
    end

    it "matches for an `Array` shape" do
      result = described_class.validate_array(value: [1], shape: Array)
      expect(result).to have_attributes(code: :array_class_allows_all_arrays, child_codes: nil)
    end

    it "matches for a 1D array of numbers against an `Integer` array shape" do
      result = described_class.validate_array(value: [1, 2, 3], shape: [Integer])
      expect(result).to have_attributes(
        code: :all_array_elements_are_valid,
        child_codes: {
          1 => { Integer => have_attributes(code: :match) },
          2 => { Integer => have_attributes(code: :match) },
          3 => { Integer => have_attributes(code: :match) },
        }
      )
    end

    it "matches for a 1D array of strings against a `String` array shape" do
      result = described_class.validate_array(value: %w[a b c], shape: [String])
      expect(result).to have_attributes(
        code: :all_array_elements_are_valid,
        child_codes: {
          "a" => { String => have_attributes(code: :match) },
          "b" => { String => have_attributes(code: :match) },
          "c" => { String => have_attributes(code: :match) },
        }
      )
    end

    it "matches for a 1D array of strings against a matching regex array shape" do
      result = described_class.validate_array(value: %w[a b c], shape: [/[a-z]/])
      expect(result).to have_attributes(
        match?: true,
        code: :all_array_elements_are_valid,
        child_codes: {
          "a" => { /[a-z]/ => have_attributes(code: :match) },
          "b" => { /[a-z]/ => have_attributes(code: :match) },
          "c" => { /[a-z]/ => have_attributes(code: :match) },
        }
      )
    end

    it "matches for a 1D mixed array of with matching shapes" do
      result = described_class.validate_array(value: [true, "a", 1], shape: [Integer, String, true])
      expect(result).to have_attributes(
        match?: true,
        code: :all_array_elements_are_valid,
        child_codes: {
          true => {
            true => have_attributes(code: :match),
            String => have_attributes(code: :no_match),
            Integer => have_attributes(code: :no_match),
          },
          "a" => {
            String => have_attributes(code: :match),
            true => have_attributes(code: :no_match),
            Integer => have_attributes(code: :no_match),
          },
          1 => {
            Integer => have_attributes(code: :match),
            true => have_attributes(code: :no_match),
            String => have_attributes(code: :no_match),
          },
        }
      )
    end

    it "does not match for a 1D mixed array without matching shapes" do
      result = described_class.validate_array(value: [1, 2, 3], shape: [String])
      expect(result).to have_attributes(
        match?: false,
        code: :some_array_elements_are_invalid,
        child_codes: {
          1 => { String => have_attributes(code: :no_match) },
          2 => { String => have_attributes(code: :no_match) },
          3 => { String => have_attributes(code: :no_match) },
        }
      )
    end

    it "does not match when the array depths do not match" do
      result = described_class.validate_array(value: [[1]], shape: [Integer])
      expect(result).to have_attributes(
        match?: false,
        code: :some_array_elements_are_invalid,
        child_codes: {
          [1] => { Integer => have_attributes(code: :class_mismatch) },
        }
      )
    end

    it "works for nested arrays" do
      result = described_class.validate_array(value: [["x"], ["a"]], shape: [[String]])
      expect(result).to have_attributes(
        match?: true,
        code: :all_array_elements_are_valid,
        child_codes: {
          ["x"] => {
            [String] => have_attributes(
              match?: true,
              code: :all_array_elements_are_valid,
              child_codes: { "x" => { String => have_attributes(code: :match) } }
            ),
          },
          ["a"] => {
            [String] => have_attributes(
              match?: true,
              code: :all_array_elements_are_valid,
              child_codes: { "a" => { String => have_attributes(code: :match) } }
            ),
          },
        }
      )
    end

    it "matches for a mixed value array that includes nested arrays" do
      result = described_class.validate_array(value: [1, ["a"]], shape: [Integer, [String]])
      expect(result).to have_attributes(
        match?: true,
        code: :all_array_elements_are_valid,
        child_codes: {
          1 => {
            Integer => have_attributes(code: :match),
            [String] => have_attributes(code: :no_match),
          },
          ["a"] => {
            [String] => have_attributes(
              match?: true,
              code: :all_array_elements_are_valid,
              child_codes: { "a" => { String => have_attributes(code: :match) } }
            ),
            Integer => have_attributes(code: :class_mismatch),
          },
        }
      )
    end
  end

  describe ".validate_hash" do
    it "rejects a non-hash value" do
      expect do
        described_class.validate_hash(value: 1, shape: Integer)
      end.to raise_error(ArgumentError, "checked value must be a hash")
    end

    it "returns an appropriate code for a directive shape" do
      result = described_class.validate_hash(value: {}, shape: "$foo:bar")
      expect(result).to have_attributes(code: :shape_is_a_directive, child_codes: nil)
    end

    it "returns a class mismatch result for a non-Hash shape" do
      result = described_class.validate_hash(value: {}, shape: 1)
      expect(result).to have_attributes(code: :class_mismatch, child_codes: nil)
    end

    it "matches for a `Hash` class shape" do
      result = described_class.validate_hash(value: { a: 1 }, shape: Hash)
      expect(result).to have_attributes(code: :hash_class_allows_all_hashes, child_codes: nil)
    end

    # TODO: design the child codes for hash results
    # - checks that all shape keys are present on the value
    # - checks that no extra keys are present on the value
    # - checks validity of each key-value pair
    # - allows extra keys via `Symbol => Object`
    # - "extra keys" validation is overridden by exact matches
    # - allows for nullable values via key => [Object, nil]
    # - allowed for missing values via key => [Object, :undefined]

    it "matches for two empty hashes" do
      result = described_class.validate_hash(value: {}, shape: {})
      expect(result).to have_attributes(code: :all_hash_elements_are_valid, child_codes: {})
    end

    pending "matches for a non-specific hash" do
      result = described_class.validate_hash(
        value: { a: 1, b: 2, c: 3 },
        shape: { Symbol => Integer }
      )
      expect(result).to have_attributes(
        code: :all_hash_elements_are_valid,
        child_codes: {
          [:a, 1] => {
            [Symbol, Integer] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          [:b, 2] => {
            [Symbol, Integer] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          [:c, 3] => {
            [Symbol, Integer] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          "$required_keys": {},
        }
      )
    end

    pending "all shape keys are required" do
      result = described_class.validate_hash(
        value: { a: 1 },
        shape: { a: Integer, b: Integer }
      )
      expect(result).to have_attributes(
        code: :some_hash_elements_are_invalid,
        child_codes: {
          [:a, 1] => {
            [Symbol, Integer] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          "$required_keys": {
            a: have_attributes(code: :match),
            b: have_attributes(code: :no_match),
          },
        }
      )
    end

    pending "exact matches override general ones" do
      result = described_class.validate_hash(
        value: { a: 1, b: "foo" },
        shape: { a: Integer, Symbol => String }
      )
      expect(result).to have_attributes(
        code: :all_hash_elements_are_valid,
        child_codes: {
          [:a, 1] => {
            [:a, Integer] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          [:b, "foo"] => {
            [:a, Integer] => have_attributes(
              code: :key_value_mismatch,
              child_codes: {
                keys: have_attributes(code: :no_match),
                values: have_attributes(code: :no_match),
              }
            ),
            [Symbol, String] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          "$required_keys": have_attributes(
            value: %i[a b],
            shape: [:a],
            code: :all_required_keys_are_present
          ),
        }
      )
    end

    pending "matches for two compatible hashes" do
      result = described_class.validate_hash(
        value: { a: 1, b: "foo" },
        shape: { a: Integer, b: String }
      )
      expect(result).to have_attributes(
        code: :all_hash_elements_are_valid,
        child_codes: {
          [:a, 1] => {
            [:a, Integer] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          [:b, "foo"] => {
            [:b, String] => have_attributes(
              code: :key_value_match,
              child_codes: {
                keys: have_attributes(code: :match),
                values: have_attributes(code: :match),
              }
            ),
          },
          "$required_keys": {
            %i[a b] => have_attributes(
              value: %i[a b],
              shape: %i[a b],
              code: :all_array_elements_are_valid
            ),
          },
        }
      )
    end
  end
end
