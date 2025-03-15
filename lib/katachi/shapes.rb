# frozen_string_literal: true

# A container for all the shapes
module Katachi::Shapes
  @shapes = {}
  def valid_key?(key) = key.is_a?(Symbol) && key.to_s.start_with?("$")
  module_function :valid_key?

  def all = @shapes
  module_function :all

  def add(key, shape)
    raise ArgumentError, "Invalid shape key: #{key}" unless valid_key?(key)

    @shapes[key] = shape
  end
  module_function :add

  def [](maybe_shape)
    # :$undefined is a special case because it's a valid key but not a shape
    # This is because it's used to represent a value that is not present in a hash
    # Afaik it's the only shape that has to look at the parent of the value being compared
    # instead of the value itself.
    return maybe_shape if maybe_shape == :$undefined || !valid_key?(maybe_shape)

    @shapes[maybe_shape] || raise(ArgumentError, "Unknown shape: #{maybe_shape}")
  end
  module_function :[]

  # A shape class for validating GUIDs
  # Here as a demonstration of how to create a custom shape
  # that can be used with the Katachi Comparator
  class Uuid
    def self.shape = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/

    def self.kt_compare(value)
      is_match = value.is_a?(String) && value.match?(shape)
      code = is_match ? :match : :mismatch
      Katachi::ComparisonResult.new(code:, value:, shape:)
    end
  end

  add(:$uuid, Uuid)
end
