# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/

  def self.valid?(value:, shapes:)
    valid_shapes = shapes.reject { |s| DIRECTIVE_REGEX === s }
    valid_shapes.any? do |s|
      case value
      when Array
        next false unless s.is_a?(Array)

        value.all? { |v| valid?(value: v, shapes: s) }
      else
        s === value # rubocop:disable Style/CaseEquality
      end
    end
  end
end
