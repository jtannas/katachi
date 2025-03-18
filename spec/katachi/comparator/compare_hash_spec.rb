# frozen_string_literal: true

RSpec.describe Katachi::Comparator, ".compare_hash" do
  it "rejects a non-hash value" do
    expect do
      described_class.compare_hash(value: 1, shape: Integer)
    end.to raise_error(ArgumentError, "checked value must be a hash")
  end

  it "returns a class mismatch result for a non-Hash shape" do
    result = described_class.compare_hash(value: {}, shape: 1)
    expect(result).to have_attributes(code: :class_mismatch, child_results: nil)
  end

  it "matches for a `Hash` class shape" do
    result = described_class.compare_hash(value: { a: 1 }, shape: Hash)
    expect(result).to have_attributes(code: :hash_class_matches_any_hash, child_results: nil)
  end

  it "matches for two empty hashes" do
    result = described_class.compare_hash(value: {}, shape: {})
    expect(result).to have_attributes(code: :hash_is_exact_match)
  end

  it "matches for two identical hashes" do
    result = described_class.compare_hash(value: { a: 1 }, shape: { a: 1 })
    expect(result).to have_attributes(code: :hash_is_exact_match)
  end

  it "matches for a single-value compatible shape" do
    result = described_class.compare_hash(value: { a: 1 }, shape: { a: Integer })
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: { a: have_attributes(code: :hash_key_exact_match) },
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: { a: have_attributes(code: :hash_key_exactly_allowed) },
        ),
        "$values": have_attributes(
          code: :hash_values_are_match,
          child_results: {
            { a: 1 } => have_attributes(
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
    result = described_class.compare_hash(value: { a: 1, b: "foo" }, shape: { a: Integer, b: String })
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: {
            a: have_attributes(code: :hash_key_exact_match),
            b: have_attributes(code: :hash_key_exact_match),
          },
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: {
            a: have_attributes(code: :hash_key_exactly_allowed),
            b: have_attributes(code: :hash_key_exactly_allowed),
          },
        ),
        "$values": have_attributes(
          code: :hash_values_are_match,
          child_results: {
            { a: 1 } => have_attributes(
              value: { a: 1 },
              shape: { a: Integer },
              code: :kv_specific_match,
              child_results: {
                Integer => have_attributes(code: :match),
              },
            ),
            { b: "foo" } => have_attributes(
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
    result = described_class.compare_hash(value: {}, shape: { a: Integer })
    expect(result).to have_attributes(
      code: :hash_is_mismatch,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_missing_keys,
          child_results: { a: have_attributes(code: :hash_key_missing) },
        ),
        "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "does not consider shape keys that are classes to be required" do
    result = described_class.compare_hash(value: {}, shape: { Symbol => Integer })
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
        "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "supports `any_of` shape keys" do
    result = described_class.compare_hash(value: { a: 1, b: 2 }, shape: { Katachi.any_of(:a, :b, :c) => Integer })

    aggregate_failures do # RSpec didn't like the usual test format with an `any_of` key
      expect(result).to have_attributes(
        code: :hash_is_match,
        child_results: {
          :$required_keys => have_attributes(code: :hash_has_no_missing_keys, child_results: Hash),
          :$extra_keys => have_attributes(
            code: :hash_has_no_extra_keys,
            child_results: {
              a: have_attributes(code: :hash_key_match_allowed),
              b: have_attributes(code: :hash_key_match_allowed),
            },
          ),
          :$values => have_attributes(code: :hash_values_are_match),
        },
      )
      expect(result.child_results[:$required_keys].child_results.keys.first).to be_a Katachi::AnyOf
    end
  end

  it "does match when the shape for a missing key matches with :$undefined" do
    result = described_class.compare_hash(value: {}, shape: { a: :$undefined })
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: { a: have_attributes(code: :hash_key_optional) },
        ),
        "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "allows forbidding a key with :$undefined" do
    result = described_class.compare_hash(value: { a: 1, b: 2 }, shape: { Symbol => Integer, a: :$undefined })
    expect(result).to have_attributes(
      code: :hash_is_mismatch,
      child_results: {
        "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
        "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
        "$values": have_attributes(
          code: :hash_values_are_mismatch,
          child_results: {
            { a: 1 } => have_attributes(
              value: { a: 1 },
              shape: { a: :$undefined },
              code: :kv_specific_mismatch,
              child_results: {
                :$undefined => have_attributes(code: :mismatch),
              },
            ),
            { b: 2 } => have_attributes(
              value: { b: 2 },
              shape: { Symbol => Integer, a: :$undefined },
              code: :kv_match,
              child_results: {
                { Symbol => Integer } => have_attributes(code: :kv_value_match),
                { a: :$undefined } => have_attributes(code: :kv_key_mismatch),
              },
            ),
          },
        ),
      },
    )
  end

  it "does not match when there are extra keys" do
    result = described_class.compare_hash(value: { a: 1, b: 2 }, shape: { a: Integer })
    expect(result).to have_attributes(
      code: :hash_is_mismatch,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: { a: have_attributes(code: :hash_key_exact_match) },
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_extra_keys,
          child_results: {
            a: have_attributes(code: :hash_key_exactly_allowed),
            b: have_attributes(code: :hash_key_not_allowed),
          },
        ),
        "$values": have_attributes(
          code: :hash_values_are_mismatch,
          child_results: {
            { a: 1 } => have_attributes(
              value: { a: 1 },
              shape: { a: Integer },
              code: :kv_specific_match,
              child_results: {
                Integer => have_attributes(code: :match),
              },
            ),
            { b: 2 } => have_attributes(
              code: :kv_mismatch,
              value: { b: 2 },
              shape: { a: Integer },
              child_results: {
                { a: Integer } => have_attributes(code: :kv_key_mismatch),
              },
            ),
          },
        ),
      },
    )
  end

  it "reports both missing and extra keys" do
    result = described_class.compare_hash(value: { a: 1 }, shape: { b: Integer })
    expect(result).to have_attributes(
      code: :hash_is_mismatch,
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
          code: :hash_values_are_mismatch,
          child_results: {
            { a: 1 } => have_attributes(
              code: :kv_mismatch,
              child_results: {
                { b: Integer } => have_attributes(match?: false),
              },
            ),
          },
        ),
      },
    )
  end

  it "matches for a single non-specific hash shapes" do
    result = described_class.compare_hash(
      value: { a: 1, b: 2 },
      shape: { Symbol => Integer },
    )
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: {
            a: have_attributes(code: :hash_key_match_allowed),
            b: have_attributes(code: :hash_key_match_allowed),
          },
        ),
        "$values": have_attributes(
          code: :hash_values_are_match,
          child_results: {
            { a: 1 } => have_attributes(
              value: { a: 1 },
              shape: { Symbol => Integer },
              code: :kv_match,
              child_results: {
                { Symbol => Integer } => have_attributes(
                  code: :kv_value_match,
                  child_results: {
                    "$kv_key": have_attributes(code: :match, value: :a, shape: Symbol),
                    "$kv_value": have_attributes(code: :match, value: 1, shape: Integer),
                  },
                ),
              },
            ),
            { b: 2 } => have_attributes(
              value: { b: 2 },
              shape: { Symbol => Integer },
              code: :kv_match,
              child_results: {
                { Symbol => Integer } => have_attributes(
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
    result = described_class.compare_hash(
      value: { a: 1, "b" => "foo" },
      shape: { Symbol => Integer, String => String },
    )
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: {
            a: have_attributes(code: :hash_key_match_allowed),
            "b" => have_attributes(code: :hash_key_match_allowed),
          },
        ),
        "$values": have_attributes(
          code: :hash_values_are_match,
          child_results: {
            { a: 1 } => have_attributes(
              value: { a: 1 },
              shape: { Symbol => Integer, String => String },
              code: :kv_match,
              child_results: {
                { Symbol => Integer } => have_attributes(
                  code: :kv_value_match,
                  child_results: {
                    "$kv_key": have_attributes(code: :match, value: :a, shape: Symbol),
                    "$kv_value": have_attributes(code: :match, value: 1, shape: Integer),
                  },
                ),
                { String => String } => have_attributes(
                  code: :kv_key_mismatch,
                  child_results: {
                    "$kv_key": have_attributes(code: :mismatch, value: :a, shape: String),
                    "$kv_value": have_attributes(code: :mismatch, value: 1, shape: String),
                  },
                ),
              },
            ),
            { "b" => "foo" } => have_attributes(
              value: { "b" => "foo" },
              shape: { Symbol => Integer, String => String },
              code: :kv_match,
              child_results: {
                { Symbol => Integer } => have_attributes(
                  code: :kv_key_mismatch,
                  child_results: {
                    "$kv_key": have_attributes(code: :mismatch, value: "b", shape: Symbol),
                    "$kv_value": have_attributes(code: :mismatch, value: "foo", shape: Integer),
                  },
                ),
                { String => String } => have_attributes(
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

  it "considers arrays full of literal values to be exact keys" do
    result = described_class.compare_hash(
      value: { %i[a b] => "b" },
      shape: { %i[a b] => String },
    )
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: { %i[a b] => have_attributes(code: :hash_key_exact_match) },
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: { %i[a b] => have_attributes(code: :hash_key_exactly_allowed) },
        ),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "considers arrays full of non-literal values to be inexact keys" do
    result = described_class.compare_hash(
      value: { %i[a b] => "b" },
      shape: { [Symbol] => String },
    )
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: {},
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: { %i[a b] => have_attributes(code: :hash_key_match_allowed) },
        ),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "considers hashes full of literal values to be exact keys" do
    result = described_class.compare_hash(
      value: { { a: :b } => "b" },
      shape: { { a: :b } => String },
    )
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: { { a: :b } => have_attributes(code: :hash_key_exact_match) },
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: { { a: :b } => have_attributes(code: :hash_key_exactly_allowed) },
        ),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "considers hashes with a non-literal values to be inexact keys" do
    result = described_class.compare_hash(
      value: { { a: :b } => "b" },
      shape: { { Symbol => Symbol } => String },
    )
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: {},
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: { { a: :b } => have_attributes(code: :hash_key_match_allowed) },
        ),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "does not consider inexact references shapes to be exact" do
    result = described_class.compare_hash(
      value: { "123e4567-e89b-12d3-a456-426614174000" => "b" },
      shape: { :$uuid => String },
    )
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: {},
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: {
            "123e4567-e89b-12d3-a456-426614174000" => have_attributes(code: :hash_key_match_allowed),
          },
        ),
        "$values": have_attributes(code: :hash_values_are_match),
      },
    )
  end

  it "exact matches override general ones" do
    result = described_class.compare_hash(
      value: { a: "wrong", b: "foo" },
      shape: { a: Integer, Symbol => String },
    )

    expect(result).to have_attributes(
      code: :hash_is_mismatch,
      child_results: {
        "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: {
            a: have_attributes(code: :hash_key_exactly_allowed),
            b: have_attributes(code: :hash_key_match_allowed),
          },
        ),
        "$values": have_attributes(
          code: :hash_values_are_mismatch,
          child_results: {
            { a: "wrong" } => have_attributes(
              value: { a: "wrong" },
              shape: { a: Integer },
              code: :kv_specific_mismatch,
              child_results: {
                Integer => have_attributes(code: :mismatch),
              },
            ),
            { b: "foo" } => have_attributes(
              value: { b: "foo" },
              shape: { a: Integer, Symbol => String },
              code: :kv_match,
              child_results: {
                { a: Integer } => have_attributes(code: :kv_key_mismatch),
                { Symbol => String } => have_attributes(code: :kv_value_match),
              },
            ),
          },
        ),
      },
    )
  end

  it "correctly finds mismatched values when the key is a general shape" do
    result = described_class.compare_hash(value: { a: "wrong" }, shape: { Symbol => Integer })
    expect(result).to have_attributes(
      code: :hash_is_mismatch,
      child_results: {
        "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
        "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
        "$values": have_attributes(
          code: :hash_values_are_mismatch,
          child_results: {
            { a: "wrong" } => have_attributes(
              value: { a: "wrong" },
              shape: { Symbol => Integer },
              code: :kv_mismatch,
              child_results: {
                { Symbol => Integer } => have_attributes(code: :kv_value_mismatch),
              },
            ),
          },
        ),
      },
    )
  end

  it "handles nested hashes correctly" do
    result = described_class.compare_hash(value: { a: { b: 1 } }, shape: { a: { b: Integer } })
    expect(result).to have_attributes(
      code: :hash_is_match,
      child_results: {
        "$required_keys": have_attributes(
          code: :hash_has_no_missing_keys,
          child_results: { a: have_attributes(code: :hash_key_exact_match) },
        ),
        "$extra_keys": have_attributes(
          code: :hash_has_no_extra_keys,
          child_results: { a: have_attributes(code: :hash_key_exactly_allowed) },
        ),
        "$values": have_attributes(
          code: :hash_values_are_match,
          child_results: {
            { a: { b: 1 } } => have_attributes(
              value: { a: { b: 1 } },
              shape: { a: { b: Integer } },
              code: :kv_specific_match,
              child_results: {
                { b: Integer } => have_attributes(
                  code: :hash_is_match,
                  child_results: {
                    "$required_keys": have_attributes(code: :hash_has_no_missing_keys),
                    "$extra_keys": have_attributes(code: :hash_has_no_extra_keys),
                    "$values": have_attributes(code: :hash_values_are_match),
                  },
                ),
              },
            ),
          },
        ),
      },
    )
  end
end
