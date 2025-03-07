# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/
  EXTRA_KEYS_FLAG = "$extra_keys"

  def self.valid?(value:, shapes:)
    valid_shapes = shapes.reject { |s| DIRECTIVE_REGEX === s }
    valid_shapes.any? do |shape|
      case value
      when Array then valid_array?(array: value, shape:)
      when Hash then valid_hash?(hash: value, shape:)
      else shape === value # rubocop:disable Style/CaseEquality
      end
    end
  end

  def self.valid_hash?(hash:, shape:)
    return true if shape == Hash
    return false unless shape.is_a?(Hash)
    return false unless shape.delete(EXTRA_KEYS_FLAG) || (hash.keys - shape.keys).empty?

    shape.all? do |k, sub_shapes|
      if hash.key?(k)
        valid?(value: hash[k], shapes: sub_shapes)
      else
        sub_shapes.include?(:undefined)
      end
    end
  end

  def self.valid_array?(array:, shape:)
    return true if shape == Array
    return false unless shape.is_a?(Array)

    array.all? { |element| valid?(value: element, shapes: shape) }
  end
end
