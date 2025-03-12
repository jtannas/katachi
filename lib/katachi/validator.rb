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

    child_results = {
      "$required_keys": validate_hash_required_keys(value:, shape:),
      "$extra_keys": validate_hash_extra_keys(value:, shape:),
      "$values": validate_hash_values(value:, shape:),
    }
    # All categories of checks must pass for the hash to be valid
    code = child_results.values.all?(&:match?) ? :hash_is_valid : :hash_is_invalid
    Katachi::ValidationResult.new(value:, shape:, code:, child_results:)
  end

  private_class_method def self.validate_hash_required_keys(value:, shape:)
    individual_checks = shape.keys.each_with_object({}) do |key, results|
      next if DIRECTIVE_REGEX === key
      next if key.is_a?(Class)

      code = if value.key?(key) then :hash_key_present
             elsif validate(value: :undefined, shape: shape[key]).match? then :hash_key_optional
             else
               :hash_key_missing
             end
      results[key] = Katachi::ValidationResult.new(value: key, shape: key, code:)
    end
    overall_code = individual_checks.values.all?(&:match?) ? :hash_has_no_missing_keys : :hash_has_missing_keys
    Katachi::ValidationResult.new(value:, shape:, code: overall_code, child_results: individual_checks)
  end

  private_class_method def self.validate_hash_extra_keys(value:, shape:)
    individual_checks = value.keys.each_with_object({}) do |key, results|
      code = :hash_key_allowed if shape.key?(key)
      code ||= begin
        shape_key_matching = shape.keys.each_with_object({}) do |shape_key, obj|
          obj[shape_key] = validate(value: key, shape: shape_key)
        end
        shape_key_matching.values.any?(&:match?) ? :hash_key_allowed : :hash_key_not_allowed
      end
      results[key] = Katachi::ValidationResult.new(value: key, shape: key, code:)
    end
    overall_code = individual_checks.values.all?(&:match?) ? :hash_has_no_extra_keys : :hash_has_extra_keys
    Katachi::ValidationResult.new(value:, shape:, code: overall_code, child_results: individual_checks)
  end

  private_class_method def self.validate_hash_values(value:, shape:)
    individual_checks = value.each_with_object({}) do |value_kv, results|
      if shape.key?(value_kv[0])
        checked_shape = shape[value_kv[0]]
        foo = validate(value: value_kv[1], shape: checked_shape)
        results[value_kv] = Katachi::ValidationResult.new(
          value: Hash[*value_kv],
          shape: shape.slice(value_kv[0]),
          code: foo.match? ? :kv_specific_match : :kv_specific_mismatch,
          child_results: {
            checked_shape => foo,
          },
        )
        next
      end
      value_kv_results = shape.each_with_object({}) do |shape_kv, kv_results|
        keys_result = validate(value: value_kv[0], shape: shape_kv[0])
        values_result = validate(value: value_kv[1], shape: shape_kv[1])
        code = if !keys_result.match? then :kv_key_mismatch
               elsif !values_result.match? then :kv_value_mismatch
               else
                 :kv_value_match
               end
        kv_results[shape_kv] = Katachi::ValidationResult.new(
          value: Hash[*value_kv],
          shape: Hash[*shape_kv],
          code:,
          child_results: {
            "$kv_key": keys_result,
            "$kv_value": values_result,
          },
        )
      end
      results[value_kv] = Katachi::ValidationResult.new(
        value: Hash[*value_kv],
        shape:,
        code: value_kv_results.values.any?(&:match?) ? :kv_match : :kv_mismatch,
        child_results: value_kv_results,
      )
    end
    overall_code = individual_checks.values.all?(&:match?) ? :hash_values_are_valid : :hash_values_are_invalid
    Katachi::ValidationResult.new(value:, shape:, code: overall_code, child_results: individual_checks)
  end

  def self.validate_array(value:, shape:)
    failure = prevalidate_array(value:, shape:)
    return failure if failure

    child_results = validate_array_elements(array: value, shape:)
    # All array elements must be valid against at least one sub_shape
    is_match = child_results.values.all?(&:match?)
    code = is_match ? :array_is_valid : :array_is_invalid
    Katachi::ValidationResult.new(value:, shape:, code:, child_results:)
  end

  private_class_method def self.prevalidate_array(value:, shape:)
    raise ArgumentError, "checked value must be an array" unless value.is_a?(Array)

    early_exit_code = if DIRECTIVE_REGEX === shape then :shape_is_a_directive
                      elsif shape == Array then :array_class_allows_all_arrays
                      elsif !shape.is_a?(Array) then :class_mismatch
                      elsif value == shape then :array_is_an_exact_match
                      elsif value.empty? then :array_is_empty
                      end
    return unless early_exit_code

    Katachi::ValidationResult.new(value:, shape:, code: early_exit_code)
  end

  private_class_method def self.validate_array_elements(array:, shape:)
    array.each_with_object({}) do |element, child_results|
      child_results[element] ||= begin
        element_checks = shape.each_with_object({}) do |sub_shape, element_results|
          element_results[sub_shape] ||= validate(value: element, shape: sub_shape)
        end
        overall_code = element_checks.values.any?(&:match?) ? :array_element_match : :array_element_mismatch
        Katachi::ValidationResult.new(value: element, shape:, code: overall_code, child_results: element_checks)
      end
    end
  end

  private_class_method def self.prevalidate_hash(value:, shape:)
    raise ArgumentError, "checked value must be a hash" unless value.is_a?(Hash)

    early_exit_code = if DIRECTIVE_REGEX === shape then :shape_is_a_directive
                      elsif shape == Hash then :hash_class_allows_all_hashes
                      elsif !shape.is_a?(Hash) then :class_mismatch
                      elsif value == shape then :hash_is_an_exact_match
                      end
    return unless early_exit_code

    Katachi::ValidationResult.new(value:, shape:, code: early_exit_code)
  end
end
