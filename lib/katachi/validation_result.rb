# frozen_string_literal: true

# A class to represent the result of a validation.
# It has a value, a shape, a code, and optionally child codes.
# The code is a symbol that represents the result of the validation.
class Katachi::ValidationResult
  CODES = {
    # General
    match: true,
    mismatch: false,
    class_mismatch: false,
    # AnyOf
    any_of_match: true,
    any_of_mismatch: false,
    # Array Overall
    array_is_empty: true,
    array_is_valid: true,
    array_is_invalid: false,
    array_is_an_exact_match: true,
    array_class_allows_all_arrays: true,
    # Array Elements
    array_element_match: true,
    array_element_mismatch: false,
    # Hashes
    hash_class_allows_all_hashes: true,
    hash_is_an_exact_match: true,
    hash_is_invalid: false,
    hash_is_valid: true,
    # Hash[extra key checks]
    hash_has_extra_keys: false,
    hash_has_no_extra_keys: true,
    # Hash[extra key checks][individual keys]
    hash_key_allowed: true,
    hash_key_not_allowed: false,
    # Hash[missing key checks]
    hash_has_missing_keys: false,
    hash_has_no_missing_keys: true,
    # Hash[missing key checks][individual keys]
    hash_key_missing: false,
    hash_key_optional: true,
    hash_key_present: true,
    # Hash[value checks]
    hash_values_are_invalid: false,
    hash_values_are_valid: true,
    # Hash[value checks][individual kv pairs] vs Shape
    kv_match: true,
    kv_mismatch: false,
    kv_specific_match: true,
    kv_specific_mismatch: false,
    # Hash[value checks][individual kv pairs] vs Shape[individual kv pairs]
    kv_key_mismatch: false,
    kv_value_match: true,
    kv_value_mismatch: false,
  }.freeze

  attr_reader :value, :shape, :code, :child_results

  def initialize(value:, shape:, code:, child_results: nil)
    raise ArgumentError, "code `#{code.inspect}` must be one of #{CODES.keys.inspect}" unless CODES.key?(code)

    @value = value
    @shape = shape
    @code = code
    @child_results = child_results
    assert_child_codes_are_valid
  end

  def match? = CODES[code]

  def to_s
    base_text = "Checked value #{value.inspect} against shape #{shape.inspect} resulted in code #{code.inspect}"
    child_results_text = child_results&.map do |k, v|
      v.to_s.split("\n").map { |line| "  #{line}" }.join("\n")
    end
    [base_text, child_results_text].compact.join("\n")
  end

  private

  def assert_child_codes_are_valid
    return unless child_results
    return if child_results.values.all? { |v| v.is_a?(Katachi::ValidationResult) }

    raise ArgumentError, "child_results must be a Hash of ValidationResult objects"
  end
end
