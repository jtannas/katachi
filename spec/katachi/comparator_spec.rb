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
  describe ".compare" do
    it "matches for two identical numbers" do
      result = described_class.compare(value: 1, shape: 1)
      expect(result).to have_attributes(code: :exact_match)
    end

    it "matches two identical arrays" do
      result = described_class.compare(value: [1, 2, 3], shape: [1, 2, 3])
      expect(result).to have_attributes(code: :array_is_exact_match)
    end

    it "matches two identical hashes" do
      result = described_class.compare(value: { a: 1, b: 2 }, shape: { a: 1, b: 2 })
      expect(result).to have_attributes(code: :hash_is_exact_match)
    end

    it "matches a string to Object" do
      result = described_class.compare(value: "foo", shape: Object)
      expect(result).to have_attributes(code: :object_class_universal_match)
    end

    it "matches an array to Object" do
      result = described_class.compare(value: [1, 2, 3], shape: Object)
      expect(result).to have_attributes(code: :object_class_universal_match)
    end

    it "matches a hash to Object" do
      result = described_class.compare(value: { a: 1, b: 2 }, shape: Object)
      expect(result).to have_attributes(code: :object_class_universal_match)
    end
  end

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
