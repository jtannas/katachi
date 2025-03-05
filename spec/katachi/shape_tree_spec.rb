# frozen_string_literal: true

RSpec.describe Katachi::ShapeTree do
  describe "#initialize" do
    it "categorizes arguments appropriately" do
      tree = described_class.new(:null, :boolean, "foo", "$foo:bar", :foo)
      expect(tree.can_be_boolean).to be true
      expect(tree.can_be_null).to be true
      expect(tree.can_be_undefined).to be false
      expect(tree.categorized).to include(
        strings: ["foo"],
        directives: ["$foo:bar"],
        shape_keys: [:foo]
      )
    end
  end

  describe "valid?" do
    it "bleargh" do
      tree = described_class.new(:null, :boolean, "foo", 3)
      expect(tree.valid?(3)).to be true
      expect(tree.valid?("foo")).to be true
      expect(tree.valid?("x")).to be true
      expect(tree.valid?(4)).to be false
    end
  end
end
