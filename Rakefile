require 'bundler/setup'
require 'rspec/core/rake_task'
begin
  require 'cucumber/rake/task'
rescue LoadError
  # noop
end

Bundler::GemHelper.install_tasks

task :default => :test

desc 'Run RSpec and (if enabled and CUCUMBER!=false) cucumber tests'
task 'test' => 'spec'

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

if defined? Cucumber::Rake::Task
  Cucumber::Rake::Task.new 'cucumber' do |t|
    t.fork = true
    t.profile = 'default'
  end
  task 'test' => 'cucumber' if ENV['CUCUMBER'] != 'false'
end

desc 'Validate the gemspec'
task 'gemspec' do
  gemspec = eval File.read(Dir['*.gemspec'].first)
  puts 'gemspec valid' if gemspec.validate
end
