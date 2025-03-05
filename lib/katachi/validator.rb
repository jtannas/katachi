# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/

  def self.validate(value:, shapes:)
    case value
    when String then validate_string(value:, shapes:)
    else raise NotImplementedError
    end
  end

  def self.valid_string?(value:, shapes:)
    shapes.any? do |shape|
      case shape
      when DIRECTIVE_REGEX then false
      when String, Regexp then shape.match?(value)
      else false # rubocop:disable Lint/DuplicateBranch
      end
    end
  end
end
