# frozen_string_literal: true

RSpec::Matchers.define :have_shape do |expected|
  diffable

  match do |value|
    if @expected_code
      Kt.compare(value:, shape: expected).code == @expected_code
    else
      Kt.compare(value:, shape: expected).match?
    end
  end

  chain :with_code do |expected_code|
    @expected_code = expected_code
  end
end

RSpec::Matchers.define :have_compare_code do |expected|
  match { |value| value.code == expected }
  diffable
end
