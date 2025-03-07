# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/

  def self.valid?(value:, shapes:)
    valid_shapes = shapes.reject { |s| DIRECTIVE_REGEX === s }
    valid_shapes.any? do |shape|
      case value
      when Array
        next false unless shape.is_a?(Array)

        value.all? { |v| valid?(value: v, shapes: shape) }
      else
        shape === value # rubocop:disable Style/CaseEquality
      end
    end
  end
end
