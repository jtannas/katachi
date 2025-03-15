# frozen_string_literal: true

RSpec.describe Katachi::Shapes::Guid do
  it "exists" do
    expect(described_class).to be_a(Class)
  end

  describe ".kt_compare" do
    it "matches a GUID" do
      expect(described_class.kt_compare("01234567-89ab-cdef-0123-456789abcdef")).to be_match
    end

    it "does not match a non-GUID" do
      expect(described_class.kt_compare("01234567-89ab-cdef-0123-456789abcdefg")).not_to be_match
    end
  end
end
