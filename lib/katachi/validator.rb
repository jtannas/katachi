# frozen_string_literal: true

require_relative "validation_result"

# Checks a given value against an array of shapes
# TODO: replace the indented strings with result objects
class Katachi::Validator # rubocop:todo Metrics/ClassLength
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

    code = shape === value ? :match : :no_match # rubocop:disable Style/CaseEquality
    Katachi::ValidationResult.new(value:, shape:, code:)
  end

  # --------------- ARRAY VALIDATION ---------------
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

    early_exit_code = if shape == Array then :array_class_allows_all_arrays
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

  # --------------- HASH VALIDATION ---------------
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

  private_class_method def self.prevalidate_hash(value:, shape:)
    raise ArgumentError, "checked value must be a hash" unless value.is_a?(Hash)

    early_exit_code = if shape == Hash then :hash_class_allows_all_hashes
                      elsif !shape.is_a?(Hash) then :class_mismatch
                      elsif value == shape then :hash_is_an_exact_match
                      end
    return unless early_exit_code

    Katachi::ValidationResult.new(value:, shape:, code: early_exit_code)
  end

  private_class_method def self.validate_hash_required_keys(value:, shape:)
    individual_checks = shape.keys.each_with_object({}) do |key, results|
      next if key.is_a?(Class)

      code = if value.key?(key) then :hash_key_present
             elsif validate(value: :$undefined, shape: shape[key]).match? then :hash_key_optional
             else
               :hash_key_missing
             end
      results[key] = Katachi::ValidationResult.new(value: key, shape: key, code:)
    end
    Katachi::ValidationResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_has_no_missing_keys : :hash_has_missing_keys,
      child_results: individual_checks,
    )
  end

  private_class_method def self.validate_hash_extra_keys(value:, shape:)
    individual_checks = value.keys.each_with_object({}) do |key, results|
      has_match = shape.keys.any? { |shape_key| validate(value: key, shape: shape_key).match? }
      results[key] = Katachi::ValidationResult.new(
        value: key,
        shape: key,
        code: has_match ? :hash_key_allowed : :hash_key_not_allowed,
      )
    end
    Katachi::ValidationResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_has_no_extra_keys : :hash_has_extra_keys,
      child_results: individual_checks,
    )
  end

  private_class_method def self.validate_hash_values(value:, shape:)
    individual_checks = value.each_with_object({}) do |value_kv, results|
      results[value_kv] = if shape.key?(value_kv[0])
                            validate_specific_kv_match(value_kv:, shape:)
                          else
                            validate_general_kv(value_kv:, shape:)
                          end
    end
    Katachi::ValidationResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_values_are_valid : :hash_values_are_invalid,
      child_results: individual_checks,
    )
  end

  private_class_method def self.validate_specific_kv_match(value_kv:, shape:)
    checked_shape = shape[value_kv[0]]
    result = validate(value: value_kv[1], shape: checked_shape)
    Katachi::ValidationResult.new(
      value: Hash[*value_kv],
      shape: shape.slice(value_kv[0]),
      code: result.match? ? :kv_specific_match : :kv_specific_mismatch,
      child_results: { checked_shape => result },
    )
  end

  private_class_method def self.validate_general_kv(value_kv:, shape:)
    value_kv_results = shape.each_with_object({}) do |shape_kv, kv_results|
      kv_results[shape_kv] = validate_individual_kv(value_kv:, shape_kv:)
    end
    Katachi::ValidationResult.new(
      value: Hash[*value_kv],
      shape:,
      code: value_kv_results.values.any?(&:match?) ? :kv_match : :kv_mismatch,
      child_results: value_kv_results,
    )
  end

  private_class_method def self.validate_individual_kv(value_kv:, shape_kv:)
    key_result = validate(value: value_kv[0], shape: shape_kv[0])
    value_result = validate(value: value_kv[1], shape: shape_kv[1])
    code = if !key_result.match? then :kv_key_mismatch
           elsif !value_result.match? then :kv_value_mismatch
           else
             :kv_value_match
           end
    Katachi::ValidationResult.new(
      value: Hash[*value_kv],
      shape: Hash[*shape_kv],
      code:,
      child_results: { "$kv_key": key_result, "$kv_value": value_result },
    )
  end
end
