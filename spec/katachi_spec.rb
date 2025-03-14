# frozen_string_literal: true

RSpec.describe Katachi do
  it "has a version number" do
    expect(Katachi::VERSION).not_to be_nil
  end

  it "validates shapes" do
    value = { a: { b: [1, "a"] } }
    shape = { a: { b: [Kt.any_of(Integer, String)] } }
    expect(Kt.validate(value:, shape:)).to be_match
  end
end
