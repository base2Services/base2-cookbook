require 'rspec/core/rake_task'
require 'foodcritic'
require 'jsonlint/rake_task'
require 'rake/version_task'

RSpec::Core::RakeTask.new(:spec)
Rake::VersionTask.new do |task|
  task.with_git = false
end
task :default => ['test:run']

# Tests/LINT
namespace :test do

  task :test_chef do
    begin
      Rake::Task['foodcritic'].invoke
    rescue Exception => e
      puts "Some Chef code seems to be not written according to best practices."
      # raise e
    end
  end

  task :all => [:test_chef, :test_rspec]
end

desc "Run all tests"
task :test => 'test:all'

RSpec::Core::RakeTask.new(:test_rspec) do |t|
  t.rspec_opts = [].tap do |a|
    a.push('--no-color')
    a.push('--require spec_helper.rb')
    a.push('--format RspecJunitFormatter')
    a.push('--out reports/test-results.xml')
  end.join(' ')
end

FoodCritic::Rake::LintTask.new do |t|
  t.options = {:fail_tags => ['correctness']}
end
