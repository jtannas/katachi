class Katachi::ValidationResult
  CODES = %i[
    match
    no_match
    shape_is_a_directive
  ]
  attr_reader :value, :shape, :code

  def initialize(value:, shape:, code:)
    raise ArgumentError, "code must be one of #{CODES.inspect}" unless CODES.include?(code)

    @value = value
    @shape = shape
    @code = code
  end
end
