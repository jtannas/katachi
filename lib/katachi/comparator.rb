# frozen_string_literal: true

require_relative "comparison_result"
require_relative "comparator/compare_array"
require_relative "comparator/compare_hash"

# Checks a given value against a shape; returns a Katachi::Result
module Katachi::Comparator
  # The main method for comparing a value against a shape
  # Most of the logic is delegated to the other methods within this module
  # In order to handle nested arrays and hashes the comparison methods are
  # often recursive.
  #
  # @param value [Object] The value to compare
  # @param shape [Object] The shape to compare against
  # @return [Katachi::ComparisonResult] The result of the comparison
  def self.compare(value:, shape:)
    retrieved_shape = Katachi::Shapes[shape]
    return retrieved_shape.kt_compare(value) if retrieved_shape.respond_to?(:kt_compare)
    return compare_equalities(value:, shape: retrieved_shape) if retrieved_shape.is_a?(Proc)
    return object_class_universal_match(value:) if retrieved_shape == Object

    case value
    when Array then compare_array(value:, shape: retrieved_shape)
    when Hash then compare_hash(value:, shape: retrieved_shape)
    else compare_equalities(value:, shape: retrieved_shape)
    end
  end

  # The method for comparing two values that are not arrays or hashes
  # It relies on the case equality operator (===) to do the heavy lifting.
  #
  # @param value [Object] The value to compare
  # @param shape [Object] The shape to compare against
  # @return [Katachi::ComparisonResult] The result of the comparison
  def self.compare_equalities(value:, shape:)
    code = if shape == value then :exact_match
           elsif shape === value then :match # rubocop:disable Style/CaseEquality
           else
             :mismatch
           end
    Katachi::ComparisonResult.new(value:, shape:, code:)
  end

  private_class_method def self.object_class_universal_match(value:)
    Katachi::ComparisonResult.new(value:, shape: Object, code: :object_class_universal_match)
  end
end
