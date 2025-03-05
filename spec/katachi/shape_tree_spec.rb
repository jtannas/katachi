# frozen_string_literal: true

RSpec.describe Katachi::ShapeTree do
  describe "#initialize" do
    it "categorizes arguments appropriately" do
      tree = described_class.new(:null, :boolean, "foo", "$foo:bar", :foo)
      expect(tree).to have_attributes(
        can_be_boolean: true,
        can_be_null: true,
        can_be_undefined: false
      )
    end
  end

  describe "#categorized" do
    it "categorizes arguments appropriately" do
      tree = described_class.new(:null, :boolean, "foo", "$foo:bar", :foo)
      expect(tree.categorized).to include(
        strings: ["foo"],
        directives: ["$foo:bar"],
        shape_keys: [:foo]
      )
    end
  end
end
