# frozen_string_literal: true

require "katachi/rspec"

RSpec.describe "predefined shapes" do # rubocop:disable RSpec/DescribeClass
  describe "uuid shape" do
    it "matches a UUID" do
      sample_uuid = "01234567-89ab-cdef-0123-456789abcdef"
      expect(sample_uuid).to have_shape(:$uuid)
    end

    it "does not match a non-UUID" do
      value = "abcdefg"
      expect(value).not_to have_shape(:$uuid)
    end
  end
end
