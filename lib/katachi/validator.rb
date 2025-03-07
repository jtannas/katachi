# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/
  EXTRA_KEYS_FLAG = "$extra_keys"

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
        next false unless shape.delete(EXTRA_KEYS_FLAG) || (value.keys - shape.keys).empty?

        shape.all? do |k, sub_shapes|
          if value.key?(k)
            valid?(value: value[k], shapes: sub_shapes)
          else
            sub_shapes.include?(:undefined)
          end
        end
      else
        shape === value # rubocop:disable Style/CaseEquality
      end
    end
  end
end
