require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

task :default => :test

desc 'Run RSpec and (if CUCUMBER!=false) cucumber tests'
task 'test' => 'spec'
task 'test' => 'cucumber' if ENV['CUCUMBER'] != 'false'

RSpec::Core::RakeTask.new 'spec'

namespace 'spec' do
  RSpec::Core::RakeTask.new 'wip' do |t|
    t.rspec_opts = '--tag wip'
    t.fail_on_error = false
  end

  RSpec::Core::RakeTask.new 'rcov' do |t|
    t.rspec_opts = ['-r simplecov']
  end
end

Cucumber::Rake::Task.new 'cucumber' do |t|
  t.fork = true
  t.profile = 'default'
end

desc 'Validate the gemspec'
task 'gemspec' do
  gemspec = eval File.read(Dir['*.gemspec'].first)
  puts 'gemspec valid' if gemspec.validate
end
