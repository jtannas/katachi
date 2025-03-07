# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/

  def self.valid?(value:, shapes:)
    valid_shapes = shapes.reject { |s| DIRECTIVE_REGEX === s }
    valid_shapes.any? do |shape|
      case value
      when Array
        next true if shape == Array
        next false unless shape.is_a?(Array)

        value.all? { |v| valid?(value: v, shapes: shape) }
      when Hash
        next true if shape == Hash
        next false unless shape.is_a?(Hash)

        value.all? { |k, v| shape.key?(k) && valid?(value: v, shapes: shape[k]) }
      else
        shape === value # rubocop:disable Style/CaseEquality
      end
    end
  end
end
