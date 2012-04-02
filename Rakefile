require 'bundler'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
Bundler::GemHelper.install_tasks

gemspec = eval(File.read(Dir["*.gemspec"].first))

task :default => [:spec, :cucumber]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts='--tag ~wip'
end

desc "Validate the gemspec"
task :gemspec do
  gemspec.validate && puts('gemspec valid')
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

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.profile = 'default'
end
