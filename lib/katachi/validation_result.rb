# frozen_string_literal: true

# A class to represent the result of a validation.
# It has a value, a shape, a code, and optionally child codes.
# The code is a symbol that represents the result of the validation.
class Katachi::ValidationResult
  CODES = {
    match: true,
    no_match: false,
    all_array_elements_are_valid: true,
    all_hash_elements_are_valid: true,
    array_class_allows_all_arrays: true,
    class_mismatch: false,
    hash_class_allows_all_hashes: true,
    key_value_match: true,
    key_value_mismatch: false,
    match_due_to_empty_array: true,
    shape_is_a_directive: false,
    some_array_elements_are_invalid: false,
    some_hash_elements_are_invalid: false,
  }.freeze

  attr_reader :value, :shape, :code, :child_codes

  def initialize(value:, shape:, code:, child_codes: nil)
    raise ArgumentError, "code `#{code.inspect}` must be one of #{CODES.keys.inspect}" unless CODES.key?(code)

    @value = value
    @shape = shape
    @code = code
    @child_codes = child_codes
  end

  def match? = CODES[code]
end
