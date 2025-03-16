# frozen_string_literal: true

require_relative "comparison_result"

# Checks a given value against a shape
# TODO: Refactor different sections into different modules
module Katachi::Comparator
  def self.compare(value:, shape:)
    retrieved_shape = Katachi::Shapes[shape]
    return retrieved_shape.kt_compare(value) if retrieved_shape.respond_to?(:kt_compare)
    return compare_equalities(value:, shape: retrieved_shape) if retrieved_shape.is_a?(Proc)

    case value
    when Array then compare_array(value:, shape: retrieved_shape)
    when Hash then compare_hash(value:, shape: retrieved_shape)
    else compare_equalities(value:, shape: retrieved_shape)
    end
  end

  def self.compare_equalities(value:, shape:)
    code = if shape == value then :exact_match
           elsif shape === value then :match # rubocop:disable Style/CaseEquality
           else
             :mismatch
           end
    Katachi::ComparisonResult.new(value:, shape:, code:)
  end

  # --------------- ARRAY VALIDATION ---------------
  def self.compare_array(value:, shape:)
    failure = precompare_array(value:, shape:)
    return failure if failure

    child_results = compare_array_elements(array: value, shape:)
    # All array elements must be valid against at least one sub_shape
    is_match = child_results.values.all?(&:match?)
    code = is_match ? :array_is_match : :array_is_mismatch
    Katachi::ComparisonResult.new(value:, shape:, code:, child_results:)
  end

  private_class_method def self.precompare_array(value:, shape:)
    raise ArgumentError, "checked value must be an array" unless value.is_a?(Array)

    early_exit_code = if shape == Array then :array_class_matches_any_array
                      elsif !shape.is_a?(Array) then :class_mismatch
                      elsif value == shape then :array_is_exact_match
                      elsif value.empty? then :array_is_empty
                      end
    return unless early_exit_code

    Katachi::ComparisonResult.new(value:, shape:, code: early_exit_code)
  end

  private_class_method def self.compare_array_elements(array:, shape:)
    array.each_with_object({}) do |element, child_results|
      child_results[element] ||= begin
        element_checks = shape.each_with_object({}) do |sub_shape, element_results|
          element_results[sub_shape] ||= compare(value: element, shape: sub_shape)
        end
        overall_code = element_checks.values.any?(&:match?) ? :array_element_match : :array_element_mismatch
        Katachi::ComparisonResult.new(value: element, shape:, code: overall_code, child_results: element_checks)
      end
    end
  end

  # --------------- HASH VALIDATION ---------------
  def self.compare_hash(value:, shape:)
    failure = precompare_hash(value:, shape:)
    return failure if failure

    child_results = {
      "$required_keys": compare_hash_required_keys(value:, shape:),
      "$extra_keys": compare_hash_extra_keys(value:, shape:),
      "$values": compare_hash_values(value:, shape:),
    }
    # All categories of checks must pass for the hash to be a match
    code = child_results.values.all?(&:match?) ? :hash_is_match : :hash_is_mismatch
    Katachi::ComparisonResult.new(value:, shape:, code:, child_results:)
  end

  private_class_method def self.precompare_hash(value:, shape:)
    raise ArgumentError, "checked value must be a hash" unless value.is_a?(Hash)

    early_exit_code = if shape == Hash then :hash_class_matches_any_hash
                      elsif !shape.is_a?(Hash) then :class_mismatch
                      elsif value == shape then :hash_is_exact_match
                      end
    return unless early_exit_code

    Katachi::ComparisonResult.new(value:, shape:, code: early_exit_code)
  end

  private_class_method def self.compare_hash_required_keys(value:, shape:)
    individual_checks = shape.keys.each_with_object({}) do |key, results|
      next if key.is_a?(Class)

      code = if value.key?(key) then :hash_key_present
             elsif compare(value: :$undefined, shape: shape[key]).match? then :hash_key_optional
             else
               :hash_key_missing
             end
      results[key] = Katachi::ComparisonResult.new(value: key, shape: key, code:)
    end
    Katachi::ComparisonResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_has_no_missing_keys : :hash_has_missing_keys,
      child_results: individual_checks,
    )
  end

  private_class_method def self.compare_hash_extra_keys(value:, shape:)
    individual_checks = value.keys.each_with_object({}) do |key, results|
      has_match = shape.keys.any? { |shape_key| compare(value: key, shape: shape_key).match? }
      results[key] = Katachi::ComparisonResult.new(
        value: key,
        shape: key,
        code: has_match ? :hash_key_allowed : :hash_key_not_allowed,
      )
    end
    Katachi::ComparisonResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_has_no_extra_keys : :hash_has_extra_keys,
      child_results: individual_checks,
    )
  end

  private_class_method def self.compare_hash_values(value:, shape:)
    individual_checks = value.each_with_object({}) do |value_kv, results|
      results[value_kv] = if shape.key?(value_kv[0])
                            compare_specific_kv(value_kv:, shape:)
                          else
                            compare_general_kv(value_kv:, shape:)
                          end
    end
    Katachi::ComparisonResult.new(
      value:,
      shape:,
      code: individual_checks.values.all?(&:match?) ? :hash_values_are_match : :hash_values_are_mismatch,
      child_results: individual_checks,
    )
  end

  private_class_method def self.compare_specific_kv(value_kv:, shape:)
    checked_shape = shape[value_kv[0]]
    result = compare(value: value_kv[1], shape: checked_shape)
    Katachi::ComparisonResult.new(
      value: Hash[*value_kv],
      shape: shape.slice(value_kv[0]),
      code: result.match? ? :kv_specific_match : :kv_specific_mismatch,
      child_results: { checked_shape => result },
    )
  end

  private_class_method def self.compare_general_kv(value_kv:, shape:)
    value_kv_results = shape.each_with_object({}) do |shape_kv, kv_results|
      kv_results[shape_kv] = compare_individual_kv(value_kv:, shape_kv:)
    end
    Katachi::ComparisonResult.new(
      value: Hash[*value_kv],
      shape:,
      code: value_kv_results.values.any?(&:match?) ? :kv_match : :kv_mismatch,
      child_results: value_kv_results,
    )
  end

  private_class_method def self.compare_individual_kv(value_kv:, shape_kv:)
    key_result = compare(value: value_kv[0], shape: shape_kv[0])
    value_result = compare(value: value_kv[1], shape: shape_kv[1])
    code = if !key_result.match? then :kv_key_mismatch
           elsif !value_result.match? then :kv_value_mismatch
           else
             :kv_value_match
           end
    Katachi::ComparisonResult.new(
      value: Hash[*value_kv],
      shape: Hash[*shape_kv],
      code:,
      child_results: { "$kv_key": key_result, "$kv_value": value_result },
    )
  end
end
