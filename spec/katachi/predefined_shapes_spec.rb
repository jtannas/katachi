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

  describe "guid shape" do
    it "matches a GUID" do
      sample_guid = "01234567-89ab-cdef-0123-456789abcdef"
      expect(sample_guid).to have_shape(:$guid)
    end

    it "does not match a non-GUID" do
      value = "abcdefg"
      expect(value).not_to have_shape(:$guid)
    end
  end
end
