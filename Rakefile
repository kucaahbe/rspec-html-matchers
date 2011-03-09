require 'bundler'
require 'rspec/core/rake_task'
Bundler::GemHelper.install_tasks

task :default => :spec

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts='--tag ~wip'
end

namespace :spec do
  RSpec::Core::RakeTask.new(:wip) do |t|
    t.rspec_opts='--tag wip'
    t.fail_on_error = false
  end

  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.rspec_opts=['-r simplecov']
  end
end
