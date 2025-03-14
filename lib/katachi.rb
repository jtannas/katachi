# frozen_string_literal: true

require_relative "katachi/version"
require_relative "katachi/exceptions"
require_relative "katachi/shape_def"
require_relative "katachi/validation_result"
require_relative "katachi/validator"
require_relative "katachi/any_of"

# A tool for describing objects in a compact and readable way
module Katachi
  def validate(**) = Validator.validate(**)
  module_function :validate

  def any_of(*shapes) = AnyOf.new(*shapes)
  module_function :any_of
end

Kt = Katachi
