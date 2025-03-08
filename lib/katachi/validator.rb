# frozen_string_literal: true

# Checks a given value against an array of shapes
class Katachi::Validator
  DIRECTIVE_REGEX = /^\$\w*:.*$/
  EXTRA_KEYS_FLAG = "$extra_keys"

  def self.validate(value:, shapes:)
    messages = []
    value_text = case value
                 when String then "\"#{value}\""
                 when Symbol then ":#{value}"
                 else value.inspect
                 end
    valid_shapes = shapes.reject { |s| DIRECTIVE_REGEX === s }
    valid_shapes.each do |shape|
      shape_text = case shape
                   when String then "\"#{shape}\""
                   when Symbol then ":#{shape}"
                   else shape.inspect
                   end
      pass_message = "=> PASS: Value `#{value_text}` matched shape `#{shape_text}`"
      fail_message = "=> FAIL: Value `#{value_text}` does not match shape `#{shape_text}`"
      case value
      when Array then messages.concat(validate_array(hash: value, shape:))
      when Hash then messages.concat(validate_hash(hash: value, shape:))
      else messages << (shape === value ? pass_message : fail_message)
      end
    end
    has_pass = messages.any? { |m| m.start_with?("=> PASS") }
    header = if has_pass
               "PASS: Value `#{value_text}` matched a shape"
             else
               "FAIL: Value `#{value_text}` does not match any of the shapes"
             end
    [header, *messages].join("\n")
  end

  def self.validate_hash(hash:, shape:)
    return [] if shape == Hash
    return ["is_not_same_class as #{shape}"] unless shape.is_a?(Hash)

    unless shape.delete(EXTRA_KEYS_FLAG)
      extra_keys = (hash.keys - shape.keys)
      return ["has extra_keys: [#{extra_keys.join(",")}]"] if extra_keys.any?
    end

    shape.all? do |k, sub_shapes|
      if hash.key?(k)
        validate(value: hash[k], shapes: sub_shapes)
      else
        sub_shapes.include?(:undefined)
      end
    end
  end

  def self.validate_array(array:, shape:, messages:)
    return [] if shape == Array
    return ["is_not_same_class as #{shape}"] unless shape.is_a?(Array)

    array.map { |element| "=> " + validate(value: element, shapes: shape) }
  end
end
