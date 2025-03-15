# frozen_string_literal: true

RSpec.describe Katachi do
  it "has a convenient abbreviation" do
    expect(Kt).to eq described_class
  end

  it "validates shapes using an intuitive syntax" do
    value = "hello_world"
    shape = String
    expect(Kt.validate(value:, shape:)).to be_match
  end

  it "supports exact matching" do
    value = "hello_world"
    shape = "hello_world"
    expect(Kt.validate(value:, shape:)).to be_match
  end

  it "supports regex matching" do
    value = "hello_world"
    shape = /hello/
    expect(Kt.validate(value:, shape:)).to be_match
  end

  it "supports range matching" do
    value = 5
    shape = 1..10
    expect(Kt.validate(value:, shape:)).to be_match
  end

  it "can use predefined shapes or you can make your own" do
    sample_guid = "123e4567-e89b-12d3-a456-426614174000"
    shape = :$guid
    expect(Kt.validate(value: sample_guid, shape:)).to be_match
  end

  it "supports matching multiple types" do
    value = [1, "a", nil, true, false].sample
    shape = Kt.any_of(Integer, String, nil, true, false)
    expect(Kt.validate(value:, shape:)).to be_match
  end

  it "lets you pass in your own matching procs to fit your specific situation" do
    value = [1, "a", 3]
    shape = ->(v) { v in [Integer, String, Integer] }
    expect(Kt.validate(value:, shape:)).to be_match
  end

  context "when validating arrays" do
    it "is not length sensitive by default" do
      value = [1, 2, 3]
      shape = [Integer]
      expect(Kt.validate(value:, shape:)).to be_match
    end

    it "matches all elements in the array" do
      value = [1, 2, "a"]
      shape = [Integer]
      expect(Kt.validate(value:, shape:)).not_to be_match
    end

    it "does not require `any_of` to match multiple types" do
      value = [1, 2, "a"]
      shape = [Integer, String]
      expect(Kt.validate(value:, shape:)).to be_match
    end

    it "supports arbitrary levels of nesting" do
      value = [1, [2, [3, 4]]]
      shape = [Integer, [Integer, [Integer, Integer]]]
      expect(Kt.validate(value:, shape:)).to be_match
    end
  end

  context "when validating hashes" do
    it "requires hash keys by default" do
      value = {}
      shape = { a: Integer }
      expect(Kt.validate(value:, shape:)).not_to be_match
    end

    it "allows optional keys" do
      value = {}
      shape = { a: Kt.any_of(Integer, :$undefined) }
      expect(Kt.validate(value:, shape:)).to be_match
    end

    it "disallows extra keys by default" do
      value = { a: 1, b: 2 }
      shape = { a: Integer }
      expect(Kt.validate(value:, shape:)).not_to be_match
    end

    it "supports matching the general form of hashes" do
      value = { a: 1, b: 2 }
      shape = { Symbol => Integer }
      expect(Kt.validate(value:, shape:)).to be_match
    end

    it "supports overriding general matches with specific types" do
      value = { first_name: "John", last_name: "Doe", dob: Time.now }
      shape = { Symbol => String, dob: Time }
      expect(Kt.validate(value:, shape:)).to be_match
    end

    it "supports arbitrary levels of nesting" do
      value = { a: { b: [1, "a"] } }
      shape = { a: { b: [Integer, String] } }
      expect(Kt.validate(value:, shape:)).to be_match
    end
  end

  it "provides detailed diagnostic information about the matching process" do
    skip if RUBY_VERSION < "3.4" # Hash#inspect changed in Ruby 3.4
    value = { a: { b: [1, "a"] } }
    shape = { a: { b: [Kt.any_of(Integer, String)] } }
    expect(Kt.validate(value:, shape:).to_s).to eq <<~RESULT.chomp
      Checked value {a: {b: [1, "a"]}} against shape {a: {b: [AnyOf[Integer, String]]}} resulted in code :hash_is_valid
        Checked value {a: {b: [1, "a"]}} against shape {a: {b: [AnyOf[Integer, String]]}} resulted in code :hash_has_no_missing_keys
          Checked value :a against shape :a resulted in code :hash_key_present
        Checked value {a: {b: [1, "a"]}} against shape {a: {b: [AnyOf[Integer, String]]}} resulted in code :hash_has_no_extra_keys
          Checked value :a against shape :a resulted in code :hash_key_allowed
        Checked value {a: {b: [1, "a"]}} against shape {a: {b: [AnyOf[Integer, String]]}} resulted in code :hash_values_are_valid
          Checked value {a: {b: [1, "a"]}} against shape {a: {b: [AnyOf[Integer, String]]}} resulted in code :kv_specific_match
            Checked value {b: [1, "a"]} against shape {b: [AnyOf[Integer, String]]} resulted in code :hash_is_valid
              Checked value {b: [1, "a"]} against shape {b: [AnyOf[Integer, String]]} resulted in code :hash_has_no_missing_keys
                Checked value :b against shape :b resulted in code :hash_key_present
              Checked value {b: [1, "a"]} against shape {b: [AnyOf[Integer, String]]} resulted in code :hash_has_no_extra_keys
                Checked value :b against shape :b resulted in code :hash_key_allowed
              Checked value {b: [1, "a"]} against shape {b: [AnyOf[Integer, String]]} resulted in code :hash_values_are_valid
                Checked value {b: [1, "a"]} against shape {b: [AnyOf[Integer, String]]} resulted in code :kv_specific_match
                  Checked value [1, "a"] against shape [AnyOf[Integer, String]] resulted in code :array_is_valid
                    Checked value 1 against shape [AnyOf[Integer, String]] resulted in code :array_element_match
                      Checked value 1 against shape [Integer, String] resulted in code :any_of_match
                        Checked value 1 against shape Integer resulted in code :match
                        Checked value 1 against shape String resulted in code :mismatch
                    Checked value "a" against shape [AnyOf[Integer, String]] resulted in code :array_element_match
                      Checked value "a" against shape [Integer, String] resulted in code :any_of_match
                        Checked value "a" against shape Integer resulted in code :mismatch
                        Checked value "a" against shape String resulted in code :match
    RESULT
  end
end
