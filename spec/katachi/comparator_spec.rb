# frozen_string_literal: true

# Class defined to always return true when used for match checking
class CustomMatchesClass
  def self.===(_other) = true
end

# Class defined to always return false when used for match checking
class CustomNoMatchesClass
  def self.===(_other) = false
end

RSpec.describe Katachi::Comparator do
  describe ".compare_equalities" do
    it "matches for two identical numbers" do
      result = described_class.compare_equalities(value: 1, shape: 1)
      expect(result).to have_attributes(code: :exact_match)
    end

    it "matches for two instances of nil" do
      result = described_class.compare_equalities(value: nil, shape: nil)
      expect(result).to have_attributes(code: :exact_match)
    end

    it "matches for two identical strings" do
      result = described_class.compare_equalities(value: "foo", shape: "foo")
      expect(result).to have_attributes(code: :exact_match)
    end

    it "is not a match for two different strings" do
      result = described_class.compare_equalities(value: "foo", shape: "foo_bar")
      expect(result).to have_attributes(code: :mismatch)
    end

    it "matches for a matching regex" do
      result = described_class.compare_equalities(value: "foo", shape: /foo/)
      expect(result).to have_attributes(code: :match)
    end

    it "is not a match for an non-matching regex" do
      result = described_class.compare_equalities(value: "foo", shape: /foo_bar/)
      expect(result).to have_attributes(code: :mismatch)
    end

    it "matches for a matching range" do
      result = described_class.compare_equalities(value: "f", shape: "a"..."z")
      expect(result).to have_attributes(code: :match)
    end

    it "returns a non-matching result for a non-matching range" do
      result = described_class.compare_equalities(value: "f", shape: "a"..."e")
      expect(result).to have_attributes(code: :mismatch)
    end

    it "is not a match for an incompatible range" do
      result = described_class.compare_equalities(value: "foo", shape: 1...10)
      expect(result).to have_attributes(code: :mismatch)
    end

    it "is a match for a compatible class" do
      result = described_class.compare_equalities(value: "foo", shape: CustomMatchesClass)
      expect(result).to have_attributes(code: :match)
    end

    it "is not a match for an incompatible class" do
      result = described_class.compare_equalities(value: "foo", shape: CustomNoMatchesClass)
      expect(result).to have_attributes(code: :mismatch)
    end

    it "is a match for a proc that is truthy" do
      result = described_class.compare_equalities(value: [1, "a"], shape: ->(v) { v in [Integer, String] })
      expect(result).to have_attributes(code: :match)
    end

    it "is not a match for a proc that is falsy" do
      result = described_class.compare_equalities(value: [1, "a"], shape: ->(v) { v in [Integer, Float] })
      expect(result).to have_attributes(code: :mismatch)
    end
  end
end
