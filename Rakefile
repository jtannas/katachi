# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test spec rubocop]

desc "Opens a console with Katachi loaded for easier experimentation"
task :console do
  require "bundler/setup"
  require "irb"
  require "katachi"
  ARGV.clear
  IRB.start(__FILE__)
end

desc "All the steps necessary to get the project ready for development"
task :setup do
  system "bundle install"
end

desc "Test the minitest integration"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end
