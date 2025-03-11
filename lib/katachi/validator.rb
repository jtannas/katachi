# frozen_string_literal: true

require_relative "validation_result"

# Checks a given value against an array of shapes
# TODO: replace the indented strings with result objects
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/
  EXTRA_KEYS_FLAG = "$extra_keys"

  def self.validate(value:, shapes:)
    messages = []
    valid_shapes = shapes.reject { |s| DIRECTIVE_REGEX === s }
    valid_shapes.each do |shape|
      case value
      when Array then messages.concat(validate_array(array: value, shape:))
      when Hash then messages.concat(validate_hash(hash: value, shape:))
      else messages << (if shape === value
                          "=> PASS: Value `#{value.inspect}` matched shape `#{shape.inspect}`"
                        else
                          "=> FAIL: Value `#{value.inspect}` does not match shape `#{shape.inspect}`"
                        end
                       )
      end
    end
    header = if value.is_a? Array
               if messages.all? { |m| m.start_with?("=> PASS") }
                 "PASS: Array `#{value.inspect}` matched a shape in #{shapes.inspect}"
               else
                 "FAIL: Array `#{value.inspect}` does not match any of the shapes in #{shapes.inspect}"
               end
             elsif messages.any? { |m| m.start_with?("=> PASS") }
               "PASS: Value `#{value.inspect}` matched a shape in #{shapes.inspect}"
             else
               "FAIL: Value `#{value.inspect}` does not match any of the shapes in #{shapes.inspect}"
             end
    [header, *messages].join("\n")
  end

  def self.validate_string(string:, shape:)
    raise ArgumentError, "checked value must be a string" unless string.is_a?(String)

    code = case shape
           when DIRECTIVE_REGEX then :shape_is_a_directive
           else shape === string ? :match : :no_match
           end

    Katachi::ValidationResult.new(value: string, shape:, code:)
  end

  # def self.validate_hash(hash:, shape:)
  #   return [] if shape == Hash
  #   return ["FAIL: is_not_same_class as #{shape}"] unless shape.is_a?(Hash)

  #   unless shape.delete(EXTRA_KEYS_FLAG)
  #     extra_keys = (hash.keys - shape.keys)
  #     return ["has extra_keys: [#{extra_keys.join(",")}]"] if extra_keys.any?
  #   end

  #   shape.all? do |k, sub_shapes|
  #     if hash.key?(k)
  #       validate(value: hash[k], shapes: sub_shapes)
  #     else
  #       sub_shapes.include?(:undefined)
  #     end
  #   end
  # end

  def self.validate_array(array:, shape:)
    return ["=> PASS: Shape `Array` allows all arrays"] if shape == Array
    unless shape.is_a?(Array)
      return ["=> FAIL: Array `#{array.inspect}` is not the same class as shape `#{shape.inspect}`"]
    end
    return ["=> PASS: Value array is empty so it matches any array shape"] if array.empty?

    results = array.map { |element| validate(value: element, shapes: shape) }
    results.map { |r| r.split("\n").map { |m| "=> " + m }.join("\n") }
  end
end
