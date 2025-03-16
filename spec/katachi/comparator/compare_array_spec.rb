# frozen_string_literal: true

RSpec.describe Katachi::Comparator, ".compare_array" do
  it "rejects checking a non-array value" do
    expect do
      described_class.compare_array(value: 1, shape: [])
    end.to raise_error(ArgumentError, "checked value must be an array")
  end

  it "returns a class mismatch result for a non-Array shape" do
    result = described_class.compare_array(value: [], shape: 1)
    expect(result).to have_attributes(code: :class_mismatch, child_results: nil)
  end

  it "matches for an empty array" do
    result = described_class.compare_array(value: [], shape: [Integer])
    expect(result).to have_attributes(code: :array_is_empty, child_results: nil)
  end

  it "matches for an `Array` shape" do
    result = described_class.compare_array(value: [1], shape: Array)
    expect(result).to have_attributes(code: :array_class_matches_any_array, child_results: nil)
  end

  it "reports an exact match for two identical arrays" do
    result = described_class.compare_array(value: [1], shape: [1])
    expect(result).to have_attributes(code: :array_is_exact_match, child_results: nil)
  end

  it "matches for a 1D array of numbers against an `Integer` array shape" do
    result = described_class.compare_array(value: [1, 2, 3], shape: [Integer])
    expect(result).to have_attributes(
      code: :array_is_match,
      child_results: {
        1 => have_attributes(value: 1, shape: [Integer], code: :array_element_match),
        2 => have_attributes(value: 2, shape: [Integer], code: :array_element_match),
        3 => have_attributes(value: 3, shape: [Integer], code: :array_element_match),
      },
    )
  end

  it "matches for a 1D array of strings against a `String` array shape" do
    result = described_class.compare_array(value: %w[a b c], shape: [String])
    expect(result).to have_attributes(
      code: :array_is_match,
      child_results: {
        "a" => have_attributes(shape: [String], code: :array_element_match),
        "b" => have_attributes(shape: [String], code: :array_element_match),
        "c" => have_attributes(shape: [String], code: :array_element_match),
      },
    )
  end

  it "matches for a 1D array of strings against a matching regex array shape" do
    result = described_class.compare_array(value: %w[a b c], shape: [/[a-z]/])
    expect(result).to have_attributes(
      match?: true,
      code: :array_is_match,
      child_results: {
        "a" => have_attributes(shape: [/[a-z]/], code: :array_element_match),
        "b" => have_attributes(shape: [/[a-z]/], code: :array_element_match),
        "c" => have_attributes(shape: [/[a-z]/], code: :array_element_match),
      },
    )
  end

  it "matches for a 1D mixed array of with matching shapes" do
    result = described_class.compare_array(value: [true, "a", 1], shape: [Integer, String, true])
    expect(result).to have_attributes(
      match?: true,
      code: :array_is_match,
      child_results: {
        true => have_attributes(
          code: :array_element_match,
          shape: [Integer, String, true],
          child_results: {
            true => have_attributes(code: :exact_match),
            String => have_attributes(code: :mismatch),
            Integer => have_attributes(code: :mismatch),
          },
        ),
        "a" => have_attributes(
          code: :array_element_match,
          child_results: {
            String => have_attributes(code: :match),
            true => have_attributes(code: :mismatch),
            Integer => have_attributes(code: :mismatch),
          },
        ),
        1 => have_attributes(
          code: :array_element_match,
          child_results: {
            Integer => have_attributes(code: :match),
            true => have_attributes(code: :mismatch),
            String => have_attributes(code: :mismatch),
          },
        ),
      },
    )
  end

  it "does not match for a 1D mixed array without matching shapes" do
    result = described_class.compare_array(value: [1, 2, 3], shape: [String])
    expect(result).to have_attributes(
      match?: false,
      code: :array_is_mismatch,
      child_results: {
        1 => have_attributes(
          code: :array_element_mismatch,
          child_results: { String => have_attributes(code: :mismatch) },
        ),
        2 => have_attributes(
          code: :array_element_mismatch,
          child_results: { String => have_attributes(code: :mismatch) },
        ),
        3 => have_attributes(
          code: :array_element_mismatch,
          child_results: { String => have_attributes(code: :mismatch) },
        ),
      },
    )
  end

  it "does not match when the array depths do not match" do
    result = described_class.compare_array(value: [[1]], shape: [Integer])
    expect(result).to have_attributes(
      match?: false,
      code: :array_is_mismatch,
      child_results: {
        [1] => have_attributes(
          code: :array_element_mismatch,
          child_results: { Integer => have_attributes(code: :class_mismatch) },
        ),
      },
    )
  end

  it "works for nested arrays" do
    result = described_class.compare_array(value: [["x"], ["a"]], shape: [[String]])
    expect(result).to have_attributes(
      match?: true,
      code: :array_is_match,
      child_results: {
        ["x"] => have_attributes(
          child_results: {
            [String] => have_attributes(
              code: :array_is_match,
              child_results: {
                "x" => have_attributes(child_results: { String => have_attributes(code: :match) }),
              },
            ),
          },
        ),
        ["a"] => have_attributes(
          child_results: {
            [String] => have_attributes(
              code: :array_is_match,
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
    result = described_class.compare_array(value: [1, ["a"]], shape: [Integer, [String]])
    expect(result).to have_attributes(
      match?: true,
      code: :array_is_match,
      child_results: {
        1 => have_attributes(
          code: :array_element_match,
          child_results: {
            Integer => have_attributes(code: :match),
            [String] => have_attributes(code: :mismatch),
          },
        ),
        ["a"] => have_attributes(
          code: :array_element_match,
          child_results: {
            Integer => have_attributes(code: :class_mismatch),
            [String] => have_attributes(
              code: :array_is_match,
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
