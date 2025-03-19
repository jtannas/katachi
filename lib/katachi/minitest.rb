# frozen_string_literal: true

require "minitest/assertions"
require "katachi"

# Minitest assertions for shape matching
module Minitest::Assertions
  def assert_shape(expected, actual)
    assert Katachi.compare(shape: expected, value: actual).match?, "Expected #{actual} to match #{expected}"
  end

  def refute_shape(expected, actual)
    refute Katachi.compare(shape: expected, value: actual).match?, "Expected #{actual} not to match #{expected}"
  end
end

# Minitest expectations for shape matching
module Minitest::Expectations
  infect_an_assertion :assert_shape, :must_match_shape
  infect_an_assertion :refute_shape, :wont_match_shape
end
