require 'bundler'
require 'rspec/core/rake_task'
require 'rake/rdoctask'
Bundler::GemHelper.install_tasks

task :default => :spec

RSpec::Core::RakeTask.new

Rake::RDocTask.new(:rdoc) do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.options << "--all"
end
