# frozen_string_literal: true

RSpec.describe Katachi::ComparisonResult do
  describe "#initialize" do
    let(:init_kwargs) { { value: 1, shape: Integer, code: :match } }

    it "is able to create a new instance" do
      expect(described_class.new(**init_kwargs)).to be_a(described_class)
    end

    it "rejects codes that are not in the CODES hash" do
      expect { described_class.new(**init_kwargs, code: :foo_bar) }.to raise_error(ArgumentError)
    end

    it "accepts a hash of child results" do
      child_results = { child: described_class.new(**init_kwargs) }
      result = described_class.new(**init_kwargs, child_results:)
      expect(result).to be_a(described_class)
    end

    it "rejects a non-hash value for child results" do
      child_results = []
      expect { described_class.new(**init_kwargs, child_results:) }.to raise_error(ArgumentError)
    end

    it "rejects a hash with non-ComparisonResult values" do
      child_results = { child: 1 }
      expect { described_class.new(**init_kwargs, child_results:) }.to raise_error(ArgumentError)
    end
  end
end
