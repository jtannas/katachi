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
      unless key.is_a?(Symbol) && key.to_s.start_with?("$")
        raise ArgumentError,
              "#{key} must be of the format `:${key}`"
      end

      @key = key
    end
  end
end
