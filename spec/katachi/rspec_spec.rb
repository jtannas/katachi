# frozen_string_literal: true

require "katachi/rspec"

RSpec.describe "Custom RSpec Matchers" do
  it "implements the `have_shape` matcher" do
    value = "hello_world"
    expect(value).to have_shape(String)
  end
end
