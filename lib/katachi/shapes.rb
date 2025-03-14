# frozen_string_literal: true

# A container for all the shapes
module Katachi::Shapes
  def shapes = ObjectSpace.each_object(Class).select { |klass| klass < Base }

  def [](key)
    raise ArgumentError, "#{key} must be of the format `:${key}`" unless key.is_a?(Symbol) && key.to_s.start_with?("$")

    shapes.find { |klass| klass.key == key }
  end

  module_function :shapes, :[]
end

require_relative "shapes/base"
require_relative "shapes/guid"
