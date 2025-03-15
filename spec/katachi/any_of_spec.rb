# frozen_string_literal: true

RSpec.describe Katachi::AnyOf do
  it "allows multiple shapes to be matched against a single value" do
    any_of = described_class[String, Integer, Float]

    expect(Katachi::Comparator.compare(value: "hello", shape: any_of)).to have_attributes(
      code: :any_of_match,
      child_results: {
        String => have_attributes(code: :match),
        Integer => have_attributes(code: :mismatch),
        Float => have_attributes(code: :mismatch),
      },
    )
  end
end
