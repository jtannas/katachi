# frozen_string_literal: true

require_relative "comparison_result"
require_relative "comparator/compare_array"
require_relative "comparator/compare_hash"

# Checks a given value against a shape; returns a Katachi::Result
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
end
