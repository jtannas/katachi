# frozen_string_literal: true

require_relative "validation_result"

# Checks a given value against an array of shapes
# TODO: replace the indented strings with result objects
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/
  EXTRA_KEYS_FLAG = "$extra_keys"

  def self.validate(value:, shape:)
    case value
    when Array then validate_array(value:, shape:)
    when Hash then validate_hash(value:, shape:)
    else validate_scalar(value:, shape:)
    end
  end

  def self.validate_scalar(value:, shape:)
    raise ArgumentError, "checked value cannot be an array" if value.is_a?(Array)
    raise ArgumentError, "checked value cannot be a hash" if value.is_a?(Hash)

    code = case shape
           when DIRECTIVE_REGEX then :shape_is_a_directive
           else shape === value ? :match : :no_match # rubocop:disable Style/CaseEquality
           end

    Katachi::ValidationResult.new(value:, shape:, code:)
  end

  def self.validate_hash(value:, shape:)
    failure = prevalidate_hash(value:, shape:)
    return failure if failure

    child_codes = validate_hash_elements(hash: value, shape: shape)
    # All hash elements must be valid against at least one corresponding sub_shape
    is_match = child_codes.values.all? { |v| v.values.any?(&:match?) }
    code = is_match ? :all_hash_elements_are_valid : :some_hash_elements_are_invalid
    Katachi::ValidationResult.new(value:, shape:, code:, child_codes:)
  end

  private_class_method def self.validate_hash_elements(hash:, shape:)
    child_codes = {}
    hash.each do |hash_pair|
      child_codes[hash_pair] ||= {}
      shape.each do |shape_pair|
        child_codes[hash_pair][shape_pair] ||= begin
          keys_result = validate(value: hash_pair[0], shape: shape_pair[0])
          values_result = validate(value: hash_pair[1], shape: shape_pair[1])
          Katachi::ValidationResult.new(
            value: hash_pair,
            shape: shape_pair,
            code: keys_result.match? && values_result.match? ? :key_value_match : :key_value_mismatch,
            child_codes: {
              keys: validate(value: hash_pair[0], shape: shape_pair[0]),
              values: validate(value: hash_pair[1], shape: shape_pair[1]),
            }
          )
        end
      end
    end
    child_codes
  end

  def self.validate_array(value:, shape:)
    failure = prevalidate_array(value:, shape:)
    return failure if failure

    child_codes = validate_array_elements(array: value, shape:)
    # All array elements must be valid against at least one sub_shape
    is_match = child_codes.values.all? { |v| v.values.any?(&:match?) }
    code = is_match ? :all_array_elements_are_valid : :some_array_elements_are_invalid
    Katachi::ValidationResult.new(value:, shape:, code:, child_codes:)
  end

  private_class_method def self.prevalidate_array(value:, shape:)
    raise ArgumentError, "checked value must be an array" unless value.is_a?(Array)

    early_exit_code = if DIRECTIVE_REGEX === shape then :shape_is_a_directive
                      elsif shape == Array then :array_class_allows_all_arrays
                      elsif !shape.is_a?(Array) then :class_mismatch
                      elsif value.empty? then :match_due_to_empty_array
                      end
    return unless early_exit_code

    Katachi::ValidationResult.new(value:, shape:, code: early_exit_code)
  end

  private_class_method def self.validate_array_elements(array:, shape:)
    array.each_with_object({}) do |element, child_codes|
      child_codes[element] ||= {}
      shape.each do |sub_shape|
        child_codes[element][sub_shape] ||= validate(value: element, shape: sub_shape)
      end
    end
  end

  private_class_method def self.prevalidate_hash(value:, shape:)
    raise ArgumentError, "checked value must be a hash" unless value.is_a?(Hash)

    early_exit_code = if DIRECTIVE_REGEX === shape then :shape_is_a_directive
                      elsif shape == Hash then :hash_class_allows_all_hashes
                      elsif !shape.is_a?(Hash) then :class_mismatch
                      end
    return unless early_exit_code

    Katachi::ValidationResult.new(value:, shape:, code: early_exit_code)
  end
end
