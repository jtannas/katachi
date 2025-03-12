# frozen_string_literal: true

# A class to represent the result of a validation.
# It has a value, a shape, a code, and optionally child codes.
# The code is a symbol that represents the result of the validation.
class Katachi::ValidationResult
  CODES = {
    match: true,
    no_match: false,
    shape_is_a_directive: false,
    match_due_to_empty_array: true,
    array_class_allows_all_arrays: true,
    all_array_elements_are_valid: true,
    some_array_elements_are_invalid: false,
    class_mismatch: false,
  }.freeze

  attr_reader :value, :shape, :code, :child_codes

  def initialize(value:, shape:, code:, child_codes: nil)
    raise ArgumentError, "code must be one of #{CODES.inspect}" unless CODES.key?(code)

    @value = value
    @shape = shape
    @code = code
    @child_codes = child_codes
  end

  def match? = CODES[code]
end
