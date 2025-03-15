# frozen_string_literal: true

RSpec::Matchers.define :have_shape do |expected|
  match { |value| Kt.compare(value:, shape: expected).match? }
  diffable
end
