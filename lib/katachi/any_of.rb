# frozen_string_literal: true

require_relative "comparison_result"
require_relative "comparator"

# AnyOf is used for allowing multiple shapes to be matched a single value.
# If any of the shapes match the value, the value is considered a match.
# If none of the shapes match the value, the value is considered a mismatch.
# AnyOf is used in the following way:
# Katachi::Comparator.compare(value, Katachi::AnyOf[shape1, shape2, shape3])
class Katachi::AnyOf
  include Enumerable

  # AnyOf[shape1, shape2, shape3] is a shortcut for AnyOf.new(shape1, shape2, shape3)
  def self.[](...) = new(...)
  def initialize(*shapes) = (@shapes = shapes)

  def each(&) = @shapes.each(&)

  # AnyOf is considered a match if any of the shapes match the value
  # If none of the shapes match the value, AnyOf is considered a mismatch
  def kt_compare(value)
    child_results = @shapes.to_h { |shape| [shape, Katachi::Comparator.compare(value:, shape:)] }
    Katachi::ComparisonResult.new(
      value:,
      shape: @shapes,
      code: child_results.values.any?(&:match?) ? :any_of_match : :any_of_mismatch,
      child_results:,
    )
  end

  # normally this `.inspect` redefinition would be for `.to_s` but Hash.to_s calls
  # inspect on the keys and values, so we have to redefine inspect instead
  # if we want a user-friendly string representation of complex objects
  def inspect = "AnyOf[#{@shapes.map(&:inspect).join(", ")}]"
end
