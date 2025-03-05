# frozen_string_literal: true

# A consistent interface for defining schemas that are then used
# as validators.
class Katachi::Shape
  RESERVED_KEYS = %i[null undefined boolean].freeze
  TYPE_ATTRIBUTES = {
    array: {},
    boolean: {},
    number: {},
    object: {},
    string: {
      pattern: [NilClass, Regexp],
      length: [NilClass, Integer, Range]
    }
  }.freeze

  attr_reader :description, :key, :input_definition, :type

  @registered_shapes = {}

  def self.register_new(key:, **input_definition)
    raise Katachi::DuplicateShapeKey.new(key:) if @registered_shapes.key?(key)

    new_shape = new(key:, **input_definition)
    new_shape.validate_input_definition!
    @registered_shapes[key] = new_shape
  end

  def self.[](key)
    @registered_shapes.fetch(key)
  rescue KeyError
    raise Katachi::MissingShapeKey.new(key:)
  end

  def initialize(key:, type:, **input_definition)
    raise ArgumentError, "#{key} is reserved for Katachi usage" if RESERVED_KEYS.include?(key)
    raise TypeError, "#{self.class.name} expects 'key' to be a symbol" unless key.is_a? Symbol
    raise Katachi::InvalidShapeType.new(type:) unless TYPE_ATTRIBUTES.key?(type)

    @key = key
    @type = type
    @input_definition = input_definition
  end

  def validate_input_definition!
    errors = TYPE_ATTRIBUTES[type].filter_map do |attr_name, attr_types|
      given_value = @input_definition[attr_name]
      next if attr_types.any? { |t| given_value.is_a? t }

      <<~ERROR.tr("\n", " ")
        #{attr_name} cannot be an instance of #{given_value.class.name};
        Allowed classes are [#{attr_types.map(&:name).join(",")}]
      ERROR
    end

    raise Katachi::InvalidShapeDefinition, errors.join('\n') if errors.any?
  end

  # TODO: Consider splitting this up into multiple subclasses
  # eg. StringShape, NumberShape, ObjectShape, etc...
  def validate_value(value)
    case type
    when :string then validate_string(value)
    else raise NotImplementedErrors # TODO
    end
  end

  private

  def validate_string(value) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength
    return ["is not a string"] unless value.is_a? String

    if (pattern = @input_definition[:pattern]) && !pattern.match?(value)
      errors << "does not match expected pattern of #{pattern}"
    end

    case (length = @input_definition[:length])
    when Number
      errors << "is not the expected length of #{length}" if value.length != length
    when Range
      errors << "is outside of expected range of #{length}" unless length.cover?(value)
    end

    errors
  end
end
