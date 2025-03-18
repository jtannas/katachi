# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  enable_coverage :branch
  enable_coverage_for_eval
  add_filter "spec/"
  minimum_coverage line: 100, branch: 100
end

require "katachi"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

RSpec.shared_examples "a pure kwargs function" do |method:,
                                                  klass: described_class,
                                                  kwargs_to_outputs: {},
                                                  kwargs_to_exceptions: {}|
  kwargs_to_outputs.each do |kwargs, expected_output|
    it "returns #{expected_output} when given #{kwargs}" do
      expect(klass.send(method, **kwargs)).to eq expected_output
    end
  end

  kwargs_to_exceptions.each do |kwargs, expected|
    it "raises <#{expected}> when given #{kwargs}", :aggregate_failures do
      expect { klass.send(method, **kwargs) }.to raise_error do |raised_error|
        expect(raised_error).to eq(expected.class)
        expect(raised_error.message).to eq(expected.message) if expected.message
      end
    end
  end
end
