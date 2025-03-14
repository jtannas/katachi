# frozen_string_literal: true

RSpec.describe Katachi::Shapes::Guid do
  it "exists" do
    expect(described_class).to be_a(Class)
  end

  it "is a subclass of Katachi::Shapes::Base" do
    expect(described_class).to be < Katachi::Shapes::Base
  end

  it "has a key of :$guid" do
    expect(described_class.key).to eq(:$guid)
  end

  describe ".kt_validate" do
    it "validates a GUID" do
      expect(described_class.kt_validate("01234567-89ab-cdef-0123-456789abcdef")).to be_match
    end

    it "does not validate a non-GUID" do
      expect(described_class.kt_validate("01234567-89ab-cdef-0123-456789abcdefg")).not_to be_match
    end
  end
end
