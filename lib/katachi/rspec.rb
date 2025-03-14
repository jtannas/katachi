# frozen_string_literal: true

RSpec::Matchers.define :have_shape do |expected|
  description { "have shape #{expected}" }
  # failure_message { |value| "failed to match; diagnostics: #{Kt.validate(value:, shape: expected)}" }
  # failure_message_when_negated do |value|
  #   [
  #     "unexpected match; diagnostics:",
  #     *Kt.validate(value:, shape: expected).to_s.split("\n").map { |line| "|> #{line}" }
  #   ]
  # end

  match do |value|
    result = Kt.validate(value:, shape: expected)
    puts result unless result.match?
    result.match?
  end

  diffable
end
