# frozen_string_literal: true

require "katachi/rspec"

RSpec.describe "Custom RSpec Matchers" do
  describe "have_shape" do
    it "passes with compatible shapes" do
      value = "hello_world"
      expect(value).to have_shape(String)
    end

    it "fails with incompatible shapes" do
      value = "hello_world"

      expect { expect(value).to have_shape(Integer) }
        .to raise_error(
          RSpec::Expectations::ExpectationNotMetError,
          a_string_including("have shape Integer"),
        )
    end
  end
end
