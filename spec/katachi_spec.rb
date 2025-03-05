# frozen_string_literal: true

RSpec.describe Katachi do
  it "has a version number" do
    expect(Katachi::VERSION).not_to be_nil
  end

  it "has a shape" do
    expect(Katachi::Shape).not_to be_nil
  end

  it "has a duplicate shape key error" do
    expect(Katachi::DuplicateShapeKey).not_to be_nil
  end

  it "has a missing shape key error" do
    expect(Katachi::MissingShapeKey).not_to be_nil
  end
end
