# frozen_string_literal: true

require_relative "lib/katachi/version"

Gem::Specification.new do |spec|
  spec.name = "katachi"
  spec.version = Katachi::VERSION
  spec.authors = ["Joel Tannas"]
  spec.email = ["jtannas@gmail.com"]

  spec.summary = "An RSpec plugin for describing and testing APIs"
  spec.description = <<~DESCRIPTION
    Experimenting with a new way of describing objects, particularly
    in regards to APIs.

    Inspired by [RSwag](https://github.com/rswag/rswag) and the challenges
    it faces with OpenAPI.
  DESCRIPTION
  spec.homepage = "https://github.com/jtannas/katachi"
  spec.license = "MIT"
  spec.required_ruby_version = [">= 3.2.0", "< 3.5"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jtannas/katachi"
  spec.metadata["changelog_uri"] = "https://github.com/jtannas/katachi/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
