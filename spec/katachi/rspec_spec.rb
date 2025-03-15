# frozen_string_literal: true

require "katachi/rspec"

RSpec.describe "Custom RSpec Matchers" do # rubocop:disable RSpec/DescribeClass
  describe "have_shape" do
    it "passes with compatible shapes" do
      value = "hello_world"
      expect(value).to have_shape(String)
    end

    it "fails with incompatible shapes" do # rubocop:disable RSpec/MultipleExpectations
      value = "hello_world"

      expect { expect(value).to have_shape(Integer) }
        .to raise_error(
          RSpec::Expectations::ExpectationNotMetError,
          a_string_including("have shape Integer"),
        )
    end
  end

  describe "have_compare_code" do
    it "passes with matching code" do
      expect(Katachi.compare(value: 1, shape: 1)).to have_compare_code(:exact_match)
    end

    it "fails with incompatible shapes" do # rubocop:disable RSpec/MultipleExpectations
      expect { expect(Katachi.compare(value: 1, shape: 2)).to have_compare_code(:exact_match) }
        .to raise_error(
          RSpec::Expectations::ExpectationNotMetError,
          a_string_including(":exact_match"),
        )
    end
  end
end
