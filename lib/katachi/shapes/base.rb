# frozen_string_literal: true

# The base class for all shape classes
class Katachi::Shapes::Base
  def initialize = raise NotImplementedError, "This class cannot be instantiated"

  class << self
    attr_reader :key

    def shape = raise NotImplementedError, "This class must implement the `shape` method"
    def kt_validate(value) = Katachi.validate(value:, shape:)

    protected

    def key=(key)
      raise ArgumentError, "#{key} must be of the format `:${key}`" unless Katachi::Shapes.valid_key?(key)

      @key = key
    end
  end
end
