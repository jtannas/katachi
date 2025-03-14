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

  # normally this redefinition would be for `.to_s` but Hash.to_s calls
  # inspect on the keys and values, so we have to redefine inspect instead
  # if we want a user-friendly string representation of complex objects
  def inspect = "AnyOf[#{@shapes.map(&:inspect).join(", ")}]"
end
