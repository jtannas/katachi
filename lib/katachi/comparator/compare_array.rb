# frozen_string_literal: true

# Checks an array against a given shape; returns a Katachi::Result
module Katachi::Comparator
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
end
