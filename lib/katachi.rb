# frozen_string_literal: true

require_relative "katachi/version"
require_relative "katachi/validation_result"
require_relative "katachi/validator"
require_relative "katachi/any_of"
require_relative "katachi/shapes"

# A tool for describing objects in a compact and readable way
module Katachi
  def validate(**) = Validator.validate(**)
  module_function :validate

  def any_of(*shapes) = AnyOf.new(*shapes)
  module_function :any_of

  def shapes = Shapes
  module_function :shapes
end

Kt = Katachi
