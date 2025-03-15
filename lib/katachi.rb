# frozen_string_literal: true

require_relative "katachi/version"
require_relative "katachi/comparison_result"
require_relative "katachi/comparator"
require_relative "katachi/any_of"
require_relative "katachi/shapes"
require_relative "katachi/predefined_shapes"

# A tool for describing objects in a compact and readable way
module Katachi
  def compare(**) = Comparator.compare(**)
  module_function :compare

  def any_of(*shapes) = AnyOf.new(*shapes)
  module_function :any_of

  def add_shape(key, shape) = Shapes.add(key, shape)
  module_function :add_shape
end

Kt = Katachi
