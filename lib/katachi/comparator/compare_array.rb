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
    # Use uniq in this method so that
    #   a) we're not doing redundant checks, and
    #   b) the results are a readable length for large array with lots of overlap
    array.uniq.to_h do |element|
      element_checks = shape.to_h { |sub_shape| [sub_shape, compare(value: element, shape: sub_shape)] }
      [
        element,
        Katachi::ComparisonResult.new(
          value: element,
          shape:,
          code: element_checks.values.any?(&:match?) ? :array_element_match : :array_element_mismatch,
          child_results: element_checks,
        )
      ]
    end
  end
end
