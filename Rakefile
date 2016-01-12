require 'rspec/core/rake_task'

desc "Run all tests"
task :test => :test_rspec

RSpec::Core::RakeTask.new(:test_rspec) do |t|
  t.rspec_opts = [].tap do |a|
    a.push('--no-color')
    a.push('--require spec_helper.rb')
    a.push('--format RspecJunitFormatter')
    a.push('--out reports/test-results.xml')
  end.join(' ')
end

task :default => :test
