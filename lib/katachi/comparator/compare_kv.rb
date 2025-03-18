# frozen_string_literal: true

# This section of the module contains the logic for comparing key-value pairs against shapes
# It is called by Katachi::Comparator.compare_hash and cannot be called directly
module Katachi::Comparator
  # Compares a single key-value pair against a shape when the key exactly matches a shape key
  # @param value_kv [Hash] A single key-value pair to compare
  # @param shape [Hash] The shape to compare against
  # @return [Katachi::ComparisonResult] The result of the comparison
  private_class_method def self.compare_specific_kv(value_kv:, shape:)
    key = value_kv.keys[0]
    result = compare(value: value_kv[key], shape: shape[key])
    Katachi::ComparisonResult.new(
      value: value_kv,
      shape: shape.slice(key),
      code: result.match? ? :kv_specific_match : :kv_specific_mismatch,
      child_results: { shape[key] => result },
    )
  end

  # Compares a single key-value pair against a shape when the key does not exactly match a shape key
  # @param value_kv [Hash] A single key-value pair to compare
  # @param shape [Hash] The shape to compare against
  # @return [Katachi::ComparisonResult] The result of the comparison
  private_class_method def self.compare_general_kv(value_kv:, shape:)
    value_kv_results = shape.keys.to_h do |s_key|
      [shape.slice(s_key), compare_individual_kv(value_kv:, shape_kv: shape.slice(s_key))]
    end
    Katachi::ComparisonResult.new(
      value: value_kv,
      shape:,
      code: value_kv_results.values.any?(&:match?) ? :kv_match : :kv_mismatch,
      child_results: value_kv_results,
    )
  end

  # Compares a single key-value pair against a single shape key-value pair
  # @param value_kv [Hash] A single key-value pair to compare
  # @param shape_kv [Hash] A single key-value pair from the shape to compare against
  # @return [Katachi::ComparisonResult] The result of the comparison
  private_class_method def self.compare_individual_kv(value_kv:, shape_kv:)
    key_result = compare(value: value_kv.keys[0], shape: shape_kv.keys[0])
    value_result = compare(value: value_kv.values[0], shape: shape_kv.values[0])
    code = if !key_result.match? then :kv_key_mismatch
           elsif !value_result.match? then :kv_value_mismatch
           else
             :kv_value_match
           end
    Katachi::ComparisonResult.new(
      value: value_kv,
      shape: shape_kv,
      code:,
      child_results: { "$kv_key": key_result, "$kv_value": value_result },
    )
  end
end
