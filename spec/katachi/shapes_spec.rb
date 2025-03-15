# frozen_string_literal: true

RSpec.describe Katachi::Shapes do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end

  describe ".all" do
    it "can return a list of shapes" do
      expect(described_class.all).to be_a(Hash)
    end

    it "includes the predefined shape Uuid" do
      expect(described_class.all).to include(:$uuid => Regexp)
    end
  end

  describe ".[]" do
    it "can find a shape by key" do
      expect(described_class[:$uuid]).to be_a Regexp
    end

    it "returns the value unchanged if it is not a valid key" do
      expect(described_class["hello"]).to eq("hello")
    end

    it "raises an error if the key does not correspond to a shape" do
      expect { described_class[:$i_do_not_exist] }.to raise_error(ArgumentError)
    end

    it "makes an exception for the special case of :$undefined" do
      expect(described_class[:$undefined]).to eq(:$undefined)
    end
  end
end
