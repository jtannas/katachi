# frozen_string_literal: true

require "minitest/autorun"
require "katachi/minitest"

class KatachiMinitestTest < Minitest::Test
  def test_assert_shape = assert_shape [1, 2, 3], [1, 2, 3]
  def test_refute_shape = refute_shape [1, 2, 3], [1, 2, 4]
end

describe "KatachiMinitestExpectations" do
  it "must match shape" do
    _([1, 2, 3]).must_match_shape [1, 2, 3]
  end

  it "won't match shape" do
    _([1, 2, 3]).wont_match_shape [1, 2, 4]
  end
end
