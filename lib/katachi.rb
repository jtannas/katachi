# frozen_string_literal: true

require_relative "katachi/version"
require_relative "katachi/comparison_result"
require_relative "katachi/comparator"
require_relative "katachi/any_of"
require_relative "katachi/shapes"
require_relative "katachi/predefined_shapes"

# A tool for describing objects in a compact and readable way
module Katachi
  def self.compare(**) = Comparator.compare(**)
  def self.any_of(*shapes) = AnyOf.new(*shapes)
  def self.add_shape(key, shape) = Shapes.add(key, shape)
end

Kt = Katachi
