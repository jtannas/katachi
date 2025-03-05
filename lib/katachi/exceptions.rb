# frozen_string_literal: true

module Katachi
  # @abstract Exceptions raised by Katachi inherit from Error
  class Error < StandardError; end

  # Exception raised when attempting to register a shape with a key that
  # is already in use
  class DuplicateShapeKey < Error
    attr_reader :key

    def initialize(key:, message: "Katachi::Shape already has a shape registered to key '#{key}'")
      @key = key
      @message = message
      super
    end
  end

  # Exception raised when attempting to access a shape that either
  # is not registered or does not exist
  class MissingShapeKey < Error
    attr_reader :key

    def initialize(key:, message: "Katachi::Shape has no shape registered to key '#{key}'")
      @key = key
      @message = message
      super
    end
  end

  # Exception raised when the `type` of shape is not supported
  class InvalidShapeType < Error
    attr_reader :type

    def initialize(
      type:,
      message: <<~ERROR
        Katachi::Shape does not support type '#{type}'
        Allowed types are:
        #{Katachi::Shape::TYPE_ATTRIBUTES.keys.map { |t| "- #{t}\n" }}
      ERROR
    )
      @type = type
      @message = message
      super
    end
  end

  # Exception raised when the additional shape information does not match
  # what is permitted by for that type
  class InvalidShapeDefinition < Error; end
end
