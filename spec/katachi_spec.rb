# frozen_string_literal: true

RSpec.describe Katachi do
  it "has a convenient abbreviation" do
    expect(Kt).to eq described_class
  end

  it "compares shapes using an intuitive syntax" do
    value = "hello_world"
    shape = String
    expect(Kt.compare(value:, shape:).match?).to be true
  end

  it "supports exact matching" do
    value = "hello_world"
    shape = "hello_world"
    expect(Kt.compare(value:, shape:).code).to eq :exact_match
  end

  it "supports regex matching" do
    value = "hello_world"
    shape = /hello/
    expect(Kt.compare(value:, shape:)).to be_match
  end

  it "supports range matching" do
    value = 5
    shape = 1..10
    expect(Kt.compare(value:, shape:)).to be_match
  end

  it "has predefined shapes to save on typing" do
    sample_uuid = "123e4567-e89b-12d3-a456-426614174000"
    shape = :$uuid
    expect(Kt.compare(value: sample_uuid, shape:)).to be_match
  end

  it "supports adding your own predefined shapes" do
    even_number = 2
    Kt.add_shape(:$even, lambda(&:even?))
    expect(Kt.compare(value: even_number, shape: :$even)).to be_match
  end

  it "supports matching multiple types" do
    value = [1, "a", nil, true, false].sample
    shape = Kt.any_of(Integer, String, nil, true, false)
    expect(Kt.compare(value:, shape:)).to be_match
  end

  it "lets you pass in your own matching procs to fit your specific situation" do
    value = [1, "a", 3]
    shape = ->(v) { v in [Integer, String, Integer] }
    expect(Kt.compare(value:, shape:)).to be_match
  end

  context "when comparing arrays" do
    it "is not length sensitive by default" do
      value = [1, 2, 3]
      shape = [Integer]
      expect(Kt.compare(value:, shape:)).to be_match
    end

    it "matches all elements in the array" do
      value = [1, 2, "a"]
      shape = [Integer]
      expect(Kt.compare(value:, shape:)).not_to be_match
    end

    it "does not require `any_of` to match multiple types" do
      value = [1, 2, "a"]
      shape = [Integer, String]
      expect(Kt.compare(value:, shape:)).to be_match
    end

    it "supports arbitrary levels of nesting" do
      value = [1, [2, [3, 4]]]
      shape = [Integer, [Integer, [Integer]]]
      expect(Kt.compare(value:, shape:)).to be_match
    end
  end

  context "when comparing hashes" do
    it "requires hash keys by default" do
      value = {}
      shape = { a: Integer }
      expect(Kt.compare(value:, shape:)).not_to be_match
    end

    it "allows optional keys" do
      value = {}
      shape = { a: Kt.any_of(Integer, :$undefined) }
      expect(Kt.compare(value:, shape:)).to be_match
    end

    it "disallows extra keys by default" do
      value = { a: 1, b: 2 }
      shape = { a: Integer }
      expect(Kt.compare(value:, shape:)).not_to be_match
    end

    it "supports matching the general form of hashes" do
      value = { a: 1, b: 2 }
      shape = { Symbol => Integer }
      expect(Kt.compare(value:, shape:)).to be_match
    end

    it "supports overriding general matches with specific types" do
      value = { first_name: "John", last_name: "Doe", dob: Time.now }
      shape = { Symbol => String, dob: Time }
      expect(Kt.compare(value:, shape:)).to be_match
    end

    it "supports arbitrary levels of nesting" do
      value = { a: { b: [1, "a"] } }
      shape = { a: { b: [Integer, String] } }
      expect(Kt.compare(value:, shape:)).to be_match
    end
  end

  it "provides detailed diagnostic information about the matching process" do
    skip if RUBY_VERSION < "3.4" # Hash#inspect changed in Ruby 3.4
    value = { a: { b: [1, "a"] } }
    shape = { a: { b: [Kt.any_of(Integer, String)] } }
    expect(Kt.compare(value:, shape:).to_s).to eq <<~RESULT.chomp
      :hash_is_match <-- compare(value: {a: {b: [1, "a"]}}, shape: {a: {b: [AnyOf[Integer, String]]}})
        :hash_has_no_missing_keys <-- compare(value: {a: {b: [1, "a"]}}, shape: {a: {b: [AnyOf[Integer, String]]}}); child_label: :$required_keys
          :hash_key_exact_match <-- compare(value: :a, shape: :a); child_label: :a
        :hash_has_no_extra_keys <-- compare(value: {a: {b: [1, "a"]}}, shape: {a: {b: [AnyOf[Integer, String]]}}); child_label: :$extra_keys
          :hash_key_exactly_allowed <-- compare(value: :a, shape: :a); child_label: :a
        :hash_values_are_match <-- compare(value: {a: {b: [1, "a"]}}, shape: {a: {b: [AnyOf[Integer, String]]}}); child_label: :$values
          :kv_specific_match <-- compare(value: {a: {b: [1, "a"]}}, shape: {a: {b: [AnyOf[Integer, String]]}}); child_label: {a: {b: [1, "a"]}}
            :hash_is_match <-- compare(value: {b: [1, "a"]}, shape: {b: [AnyOf[Integer, String]]}); child_label: {b: [AnyOf[Integer, String]]}
              :hash_has_no_missing_keys <-- compare(value: {b: [1, "a"]}, shape: {b: [AnyOf[Integer, String]]}); child_label: :$required_keys
                :hash_key_exact_match <-- compare(value: :b, shape: :b); child_label: :b
              :hash_has_no_extra_keys <-- compare(value: {b: [1, "a"]}, shape: {b: [AnyOf[Integer, String]]}); child_label: :$extra_keys
                :hash_key_exactly_allowed <-- compare(value: :b, shape: :b); child_label: :b
              :hash_values_are_match <-- compare(value: {b: [1, "a"]}, shape: {b: [AnyOf[Integer, String]]}); child_label: :$values
                :kv_specific_match <-- compare(value: {b: [1, "a"]}, shape: {b: [AnyOf[Integer, String]]}); child_label: {b: [1, "a"]}
                  :array_is_match <-- compare(value: [1, "a"], shape: [AnyOf[Integer, String]]); child_label: [AnyOf[Integer, String]]
                    :array_element_match <-- compare(value: 1, shape: [AnyOf[Integer, String]]); child_label: 1
                      :any_of_match <-- compare(value: 1, shape: [Integer, String]); child_label: AnyOf[Integer, String]
                        :match <-- compare(value: 1, shape: Integer); child_label: Integer
                        :mismatch <-- compare(value: 1, shape: String); child_label: String
                    :array_element_match <-- compare(value: "a", shape: [AnyOf[Integer, String]]); child_label: "a"
                      :any_of_match <-- compare(value: "a", shape: [Integer, String]); child_label: AnyOf[Integer, String]
                        :mismatch <-- compare(value: "a", shape: Integer); child_label: Integer
                        :match <-- compare(value: "a", shape: String); child_label: String
    RESULT
  end

  context "when used with RSpec" do
    require "katachi/rspec"

    it "provides a custom `have_shape` matcher" do
      value = "hello_world"
      expect(value).to have_shape(String)
    end

    it "provides a custom `have_compare_code` matcher" do
      expect(Kt.compare(value: 1, shape: 1)).to have_compare_code(:exact_match)
    end

    it "allows combining the two" do
      expect("foo").to have_shape("foo").with_code(:exact_match)
    end
  end
end
