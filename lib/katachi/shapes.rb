# frozen_string_literal: true

# A container for all the shapes
module Katachi::Shapes
  @shapes = {}
  def self.valid_key?(key) = key.is_a?(Symbol) && key.to_s.start_with?("$")
  def self.all = @shapes

  def self.add(key, shape)
    raise ArgumentError, "Invalid shape key: #{key}" unless valid_key?(key)

    @shapes[key] = shape
  end

  def self.[](maybe_shape)
    # :$undefined is a special case because it's a valid key but not a shape
    # This is because it's used to represent a value that is not present in a hash
    # Afaik it's the only shape that has to look at the parent of the value being compared
    # instead of the value itself.
    return maybe_shape if maybe_shape == :$undefined || !valid_key?(maybe_shape)

    @shapes[maybe_shape] || raise(ArgumentError, "Unknown shape: #{maybe_shape}")
  end
end
