# frozen_string_literal: true

# Checks a given value against an array of shapes
# Likely to change substantially with future refactors via `===`
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/

  def self.valid?(value:, shapes:)
    case value
    when String then valid_string?(value:, shapes:)
    when Number then valid_number?(value:, shapes:)
    when TrueClass, FalseClass then valid_boolean?(value:, shapes:)
    when NilClass then valid_null?(shapes:)
    else raise NotImplementedError
    end
  end

  def self.valid_string?(value:, shapes:)
    shapes.any? { |shape| !(DIRECTIVE_REGEX === shape) && shape === value }
  end

  def self.valid_number?(value:, shapes:)
    shapes.any? { |shape| !(DIRECTIVE_REGEX === shape) && shape === value }
  end

  def self.valid_boolean?(value:, shapes:) = shapes.include?(value)

  def self.valid_null?(shapes:) = shapes.include?(nil)
end
