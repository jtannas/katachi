# frozen_string_literal: true

RSpec.describe Katachi::Shapes do
  it "is a module" do
    expect(described_class).to be_a(Module)
  end

  describe ".shapes" do
    it "can return a list of shapes" do
      expect(described_class.shapes).to all(be < Katachi::Shapes::Base)
    end

    it "includes the predefined shape Guid" do
      expect(described_class.shapes).to include(Katachi::Shapes::Guid)
    end
  end

  describe ".[]" do
    it "can find a shape by key" do
      expect(described_class[:$guid]).to eq(Katachi::Shapes::Guid)
    end

    it "raises an error if the key is not a symbol" do
      expect { described_class["guid"] }.to raise_error(ArgumentError)
    end

    it "raises an error if the key does not start with a dollar sign" do
      expect { described_class[:guid] }.to raise_error(ArgumentError)
    end
  end
end
