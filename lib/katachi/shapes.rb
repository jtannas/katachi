# frozen_string_literal: true

# A container for all the shapes
module Katachi::Shapes
  def shapes = ObjectSpace.each_object(Class).select { |klass| klass < Base }

  def [](maybe_shape)
    # :$undefined is a special case because it's a valid key but not a shape
    # This is because it's used to represent a value that is not present in a hash
    # Afaik it's the only shape that has to look at the parent of the value being validated
    # instead of the value itself.
    return maybe_shape if maybe_shape == :$undefined || !valid_key?(maybe_shape)

    shapes.find { |klass| klass.key == maybe_shape } || raise(ArgumentError, "Unknown shape: #{maybe_shape}")
  end

  def valid_key?(key) = key.is_a?(Symbol) && key.to_s.start_with?("$")

  module_function :shapes, :[], :valid_key?
end

require_relative "shapes/base"
require_relative "shapes/guid"
