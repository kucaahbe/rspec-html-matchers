require 'bundler'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

suites = [:spec]
suites << :cucumber unless ENV['NO_CUCUMBER'] == 'true'
task :default => suites

desc 'Validate the gemspec'
task :gemspec do
  gemspec = eval(File.read(Dir['*.gemspec'].first))
  gemspec.validate && puts('gemspec valid')
end

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  RSpec::Core::RakeTask.new(:wip) do |t|
    t.rspec_opts='--tag wip'
    t.fail_on_error = false
  end

  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rspec_opts=['-r simplecov']
  end
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.profile = 'default'
end
