# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/

  def self.validate(value:, shapes:)
    case value
    when String then validate_string(value:, shapes:)
    when Number then validate_number(value:, shapes:)
    else raise NotImplementedError
    end
  end

  def self.valid_string?(value:, shapes:)
    shapes.any? { |shape| !(DIRECTIVE_REGEX === shape) && shape === value }
  end

  def self.valid_number?(value:, shapes:)
    shapes.any? { |shape| !(DIRECTIVE_REGEX === shape) && shape === value }
  end
end
