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
      expect(result).to have_attributes(code: :shape_is_a_directive, child_results: nil)
    end

    it "returns a class mismatch result for a non-Array shape" do
      result = described_class.validate_array(value: [], shape: 1)
      expect(result).to have_attributes(code: :class_mismatch, child_results: nil)
    end

    it "matches for an empty array" do
      result = described_class.validate_array(value: [], shape: [Integer])
      expect(result).to have_attributes(code: :array_is_empty, child_results: nil)
    end

    it "matches for an `Array` shape" do
      result = described_class.validate_array(value: [1], shape: Array)
      expect(result).to have_attributes(code: :array_class_allows_all_arrays, child_results: nil)
    end

    it "reports an exact match for two identical arrays" do
      result = described_class.validate_array(value: [1], shape: [1])
      expect(result).to have_attributes(code: :array_is_an_exact_match, child_results: nil)
    end

    it "matches for a 1D array of numbers against an `Integer` array shape" do
      result = described_class.validate_array(value: [1, 2, 3], shape: [Integer])
      expect(result).to have_attributes(
        code: :array_is_valid,
        child_results: {
          1 => have_attributes(value: 1, shape: [Integer], code: :array_element_match),
          2 => have_attributes(value: 2, shape: [Integer], code: :array_element_match),
          3 => have_attributes(value: 3, shape: [Integer], code: :array_element_match),
        },
      )
    end

    it "matches for a 1D array of strings against a `String` array shape" do
      result = described_class.validate_array(value: %w[a b c], shape: [String])
      expect(result).to have_attributes(
        code: :array_is_valid,
        child_results: {
          "a" => have_attributes(shape: [String], code: :array_element_match),
          "b" => have_attributes(shape: [String], code: :array_element_match),
          "c" => have_attributes(shape: [String], code: :array_element_match),
        },
      )
    end

    it "matches for a 1D array of strings against a matching regex array shape" do
      result = described_class.validate_array(value: %w[a b c], shape: [/[a-z]/])
      expect(result).to have_attributes(
        match?: true,
        code: :array_is_valid,
        child_results: {
          "a" => have_attributes(shape: [/[a-z]/], code: :array_element_match),
          "b" => have_attributes(shape: [/[a-z]/], code: :array_element_match),
          "c" => have_attributes(shape: [/[a-z]/], code: :array_element_match),
        },
      )
    end

    it "matches for a 1D mixed array of with matching shapes" do
      result = described_class.validate_array(value: [true, "a", 1], shape: [Integer, String, true])
      expect(result).to have_attributes(
        match?: true,
        code: :array_is_valid,
        child_results: {
          true => have_attributes(
            code: :array_element_match,
            shape: [Integer, String, true],
            child_results: {
              true => have_attributes(code: :match),
              String => have_attributes(code: :no_match),
              Integer => have_attributes(code: :no_match),
            },
          ),
          "a" => have_attributes(
            code: :array_element_match,
            child_results: {
              String => have_attributes(code: :match),
              true => have_attributes(code: :no_match),
              Integer => have_attributes(code: :no_match),
            },
          ),
          1 => have_attributes(
            code: :array_element_match,
            child_results: {
              Integer => have_attributes(code: :match),
              true => have_attributes(code: :no_match),
              String => have_attributes(code: :no_match),
            },
          ),
        },
      )
    end

    it "does not match for a 1D mixed array without matching shapes" do
      result = described_class.validate_array(value: [1, 2, 3], shape: [String])
      expect(result).to have_attributes(
        match?: false,
        code: :array_is_invalid,
        child_results: {
          1 => have_attributes(
            code: :array_element_mismatch,
            child_results: { String => have_attributes(code: :no_match) },
          ),
          2 => have_attributes(
            code: :array_element_mismatch,
            child_results: { String => have_attributes(code: :no_match) },
          ),
          3 => have_attributes(
            code: :array_element_mismatch,
            child_results: { String => have_attributes(code: :no_match) },
          ),
        },
      )
    end

    it "does not match when the array depths do not match" do
      result = described_class.validate_array(value: [[1]], shape: [Integer])
      expect(result).to have_attributes(
        match?: false,
        code: :array_is_invalid,
        child_results: {
          [1] => have_attributes(
            code: :array_element_mismatch,
            child_results: { Integer => have_attributes(code: :class_mismatch) },
          ),
        },
      )
    end

    it "works for nested arrays" do
      result = described_class.validate_array(value: [["x"], ["a"]], shape: [[String]])
      expect(result).to have_attributes(
        match?: true,
        code: :array_is_valid,
        child_results: {
          ["x"] => have_attributes(
            child_results: {
              [String] => have_attributes(
                code: :array_is_valid,
                child_results: {
                  "x" => have_attributes(child_results: { String => have_attributes(code: :match) }),
                },
              ),
            },
          ),
          ["a"] => have_attributes(
            child_results: {
              [String] => have_attributes(
                code: :array_is_valid,
                child_results: {
                  "a" => have_attributes(child_results: { String => have_attributes(code: :match) }),
                },
              ),
            },
          ),
        },
      )
    end

    it "matches for a mixed value array that includes nested arrays" do
      result = described_class.validate_array(value: [1, ["a"]], shape: [Integer, [String]])
      expect(result).to have_attributes(
        match?: true,
        code: :array_is_valid,
        child_results: {
          1 => have_attributes(
            code: :array_element_match,
            child_results: {
              Integer => have_attributes(code: :match),
              [String] => have_attributes(code: :no_match),
            },
          ),
          ["a"] => have_attributes(
            code: :array_element_match,
            child_results: {
              Integer => have_attributes(code: :class_mismatch),
              [String] => have_attributes(
                code: :array_is_valid,
                child_results: {
                  "a" => have_attributes(child_results: { String => have_attributes(code: :match) }),
                },
              ),
            },
          ),
        },
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
      expect(result).to have_attributes(code: :shape_is_a_directive, child_results: nil)
    end

    it "returns a class mismatch result for a non-Hash shape" do
      result = described_class.validate_hash(value: {}, shape: 1)
      expect(result).to have_attributes(code: :class_mismatch, child_results: nil)
    end

    it "matches for a `Hash` class shape" do
      result = described_class.validate_hash(value: { a: 1 }, shape: Hash)
      expect(result).to have_attributes(code: :hash_class_allows_all_hashes, child_results: nil)
    end

    it "matches for two empty hashes" do
      result = described_class.validate_hash(value: {}, shape: {})
      expect(result).to have_attributes(code: :hash_is_an_exact_match)
    end

    it "matches for two identical hashes" do
      result = described_class.validate_hash(value: { a: 1 }, shape: { a: 1 })
      expect(result).to have_attributes(code: :hash_is_an_exact_match)
    end

    it "matches for a single-value compatible shape" do
      result = described_class.validate_hash(value: { a: 1 }, shape: { a: Integer })
      expect(result).to have_attributes(
        code: :hash_is_valid,
        child_results: {
          "$required_keys": have_attributes(
            code: :hash_has_no_missing_keys,
            child_results: { a: have_attributes(code: :hash_key_present) },
          ),
          "$extra_keys": have_attributes(
            code: :hash_has_no_extra_keys,
            child_results: { a: have_attributes(code: :hash_key_allowed) },
          ),
          "$values": have_attributes(
            code: :hash_values_are_valid,
            child_results: {
              [:a, 1] => have_attributes(
                value: { a: 1 },
                shape: { a: Integer },
                code: :kv_specific_match,
                child_results: {
                  Integer => have_attributes(code: :match),
                },
              ),
            },
          ),
        },
      )
    end

    it "matches for a two-value compatible shape" do
      result = described_class.validate_hash(value: { a: 1, b: "foo" }, shape: { a: Integer, b: String })
      expect(result).to have_attributes(
        code: :hash_is_valid,
        child_results: {
          "$required_keys": have_attributes(
            code: :hash_has_no_missing_keys,
            child_results: {
              a: have_attributes(code: :hash_key_present),
              b: have_attributes(code: :hash_key_present),
            },
          ),
          "$extra_keys": have_attributes(
            code: :hash_has_no_extra_keys,
            child_results: {
              a: have_attributes(code: :hash_key_allowed),
              b: have_attributes(code: :hash_key_allowed),
            },
          ),
          "$values": have_attributes(
            code: :hash_values_are_valid,
            child_results: {
              [:a, 1] => have_attributes(
                value: { a: 1 },
                shape: { a: Integer },
                code: :kv_specific_match,
                child_results: {
                  Integer => have_attributes(code: :match),
                },
              ),
              [:b, "foo"] => have_attributes(
                value: { b: "foo" },
                shape: { b: String },
                code: :kv_specific_match,
                child_results: {
                  String => have_attributes(code: :match),
                },
              ),
            },
          ),
        },
      )
    end

    it "does not match when there are missing keys" do
      result = described_class.validate_hash(value: {}, shape: { a: Integer })
      expect(result).to have_attributes(
        code: :hash_is_invalid,
        child_results: {
          "$required_keys": have_attributes(
            code: :hash_has_missing_keys,
            child_results: { a: have_attributes(code: :hash_key_missing) },
          ),
          "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
          "$values": have_attributes(code: :hash_values_are_valid),
        },
      )
    end

    it "does match when the shape for a missing key matches with :undefined" do
      result = described_class.validate_hash(value: {}, shape: { a: :undefined })
      expect(result).to have_attributes(
        code: :hash_is_valid,
        child_results: {
          "$required_keys": have_attributes(
            code: :hash_has_no_missing_keys,
            child_results: { a: have_attributes(code: :hash_key_optional) },
          ),
          "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
          "$values": have_attributes(code: :hash_values_are_valid),
        },
      )
    end

    it "does not match when there are extra keys" do
      result = described_class.validate_hash(value: { a: 1, b: 2 }, shape: { a: Integer })
      expect(result).to have_attributes(
        code: :hash_is_invalid,
        child_results: {
          "$required_keys": have_attributes(
            code: :hash_has_no_missing_keys,
            child_results: { a: have_attributes(code: :hash_key_present) },
          ),
          "$extra_keys": have_attributes(
            code: :hash_has_extra_keys,
            child_results: {
              a: have_attributes(code: :hash_key_allowed),
              b: have_attributes(code: :hash_key_not_allowed),
            },
          ),
          "$values": have_attributes(
            code: :hash_values_are_invalid,
            child_results: {
              [:a, 1] => have_attributes(
                value: { a: 1 },
                shape: { a: Integer },
                code: :kv_specific_match,
                child_results: {
                  Integer => have_attributes(code: :match),
                },
              ),
              [:b, 2] => have_attributes(
                code: :kv_mismatch,
                value: { b: 2 },
                shape: { a: Integer },
                child_results: {
                  [:a, Integer] => have_attributes(code: :kv_key_mismatch),
                },
              ),
            },
          ),
        },
      )
    end

    it "reports both missing and extra keys" do
      result = described_class.validate_hash(value: { a: 1 }, shape: { b: Integer })
      expect(result).to have_attributes(
        code: :hash_is_invalid,
        child_results: {
          "$required_keys": have_attributes(
            code: :hash_has_missing_keys,
            child_results: { b: have_attributes(code: :hash_key_missing) },
          ),
          "$extra_keys": have_attributes(
            code: :hash_has_extra_keys,
            child_results: { a: have_attributes(code: :hash_key_not_allowed) },
          ),
          "$values": have_attributes(
            code: :hash_values_are_invalid,
            child_results: {
              [:a, 1] => have_attributes(
                code: :kv_mismatch,
                child_results: {
                  [:b, Integer] => have_attributes(match?: false),
                },
              ),
            },
          ),
        },
      )
    end

    it "matches for a single non-specific hash shapes" do
      result = described_class.validate_hash(
        value: { a: 1, b: 2 },
        shape: { Symbol => Integer },
      )
      expect(result).to have_attributes(
        code: :hash_is_valid,
        child_results: {
          "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
          "$extra_keys": have_attributes(
            code: :hash_has_no_extra_keys,
            child_results: {
              a: have_attributes(code: :hash_key_allowed),
              b: have_attributes(code: :hash_key_allowed),
            },
          ),
          "$values": have_attributes(
            code: :hash_values_are_valid,
            child_results: {
              [:a, 1] => have_attributes(
                value: { a: 1 },
                shape: { Symbol => Integer },
                code: :kv_match,
                child_results: {
                  [Symbol, Integer] => have_attributes(
                    code: :kv_value_match,
                    child_results: {
                      "$kv_key": have_attributes(code: :match, value: :a, shape: Symbol),
                      "$kv_value": have_attributes(code: :match, value: 1, shape: Integer),
                    },
                  ),
                },
              ),
              [:b, 2] => have_attributes(
                value: { b: 2 },
                shape: { Symbol => Integer },
                code: :kv_match,
                child_results: {
                  [Symbol, Integer] => have_attributes(
                    code: :kv_value_match,
                    child_results: {
                      "$kv_key": have_attributes(code: :match, value: :b, shape: Symbol),
                      "$kv_value": have_attributes(code: :match, value: 2, shape: Integer),
                    },
                  ),
                },
              ),
            },
          ),
        },
      )
    end

    it "matches for a two non-specific hash shapes" do
      result = described_class.validate_hash(
        value: { a: 1, "b" => "foo" },
        shape: { Symbol => Integer, String => String },
      )

      expect(result).to have_attributes(
        code: :hash_is_valid,
        child_results: {
          "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
          "$extra_keys": have_attributes(
            code: :hash_has_no_extra_keys,
            child_results: {
              a: have_attributes(code: :hash_key_allowed),
              "b" => have_attributes(code: :hash_key_allowed),
            },
          ),
          "$values": have_attributes(
            code: :hash_values_are_valid,
            child_results: {
              [:a, 1] => have_attributes(
                value: { a: 1 },
                shape: { Symbol => Integer, String => String },
                code: :kv_match,
                child_results: {
                  [Symbol, Integer] => have_attributes(
                    code: :kv_value_match,
                    child_results: {
                      "$kv_key": have_attributes(code: :match, value: :a, shape: Symbol),
                      "$kv_value": have_attributes(code: :match, value: 1, shape: Integer),
                    },
                  ),
                  [String, String] => have_attributes(
                    code: :kv_key_mismatch,
                    child_results: {
                      "$kv_key": have_attributes(code: :no_match, value: :a, shape: String),
                      "$kv_value": have_attributes(code: :no_match, value: 1, shape: String),
                    },
                  ),
                },
              ),
              %w[b foo] => have_attributes(
                value: { "b" => "foo" },
                shape: { Symbol => Integer, String => String },
                code: :kv_match,
                child_results: {
                  [Symbol, Integer] => have_attributes(
                    code: :kv_key_mismatch,
                    child_results: {
                      "$kv_key": have_attributes(code: :no_match, value: "b", shape: Symbol),
                      "$kv_value": have_attributes(code: :no_match, value: "foo", shape: Integer),
                    },
                  ),
                  [String, String] => have_attributes(
                    code: :kv_value_match,
                    child_results: {
                      "$kv_key": have_attributes(code: :match, value: "b", shape: String),
                      "$kv_value": have_attributes(code: :match, value: "foo", shape: String),
                    },
                  ),
                },
              ),
            },
          ),
        },
      )
    end

    it "exact matches override general ones" do
      result = described_class.validate_hash(
        value: { a: 1, b: "foo" },
        shape: { a: Integer, Symbol => String },
      )

      expect(result).to have_attributes(
        code: :hash_is_valid,
        child_results: {
          "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
          "$extra_keys": have_attributes(
            code: :hash_has_no_extra_keys,
            child_results: {
              a: have_attributes(code: :hash_key_allowed),
              b: have_attributes(code: :hash_key_allowed),
            },
          ),
          "$values": have_attributes(
            code: :hash_values_are_valid,
            child_results: {
              [:a, 1] => have_attributes(
                value: { a: 1 },
                shape: { a: Integer },
                code: :kv_specific_match,
                child_results: {
                  Integer => have_attributes(code: :match),
                },
              ),
              [:b, "foo"] => have_attributes(
                value: { b: "foo" },
                shape: { a: Integer, Symbol => String },
                code: :kv_match,
                child_results: {
                  [:a, Integer] => have_attributes(code: :kv_key_mismatch),
                  [Symbol, String] => have_attributes(code: :kv_value_match),
                },
              ),
            },
          ),
        },
      )
    end
  end
end
