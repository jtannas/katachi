# frozen_string_literal: true

require_relative "validation_result"
require_relative "validator"

# AnyOf is used for allowing multiple shapes to be matched a single value.
# If any of the shapes match the value, the value is considered valid.
# If none of the shapes match the value, the value is considered invalid.
# AnyOf is used in the following way:
# Katachi::Validator.validate(value, Katachi::AnyOf[shape1, shape2, shape3])
class Katachi::AnyOf
  def self.[](...) = new(...)
  def initialize(*shapes) = (@shapes = shapes)

  def kt_validate(value)
    child_results = @shapes.each_with_object({}) do |shape, results|
      results[shape] = Katachi::Validator.validate(value:, shape:)
    end

    Katachi::ValidationResult.new(
      value:,
      shape: @shapes,
      code: child_results.values.any?(&:match?) ? :any_of_match : :any_of_mismatch,
      child_results:,
    )
  end
end
