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

  it "can use predefined shapes or you can make your own" do
    sample_guid = "123e4567-e89b-12d3-a456-426614174000"
    shape = :$guid
    expect(Kt.validate(value: sample_guid, shape:)).to be_match
  end

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

  it "lets you pass in your own matching procs to fit your specific situation" do
    value = [1, 2, 3]
    shape = ->(v) { v in [Integer, Integer, Integer] }
    expect(Kt.validate(value:, shape:)).to be_match
  end

  it "provides detailed diagnostic information about the matching process" do
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
