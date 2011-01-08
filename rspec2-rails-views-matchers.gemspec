# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rspec/rails/views/matchers/version"

Gem::Specification.new do |s|
  s.name        = "rspec2-rails-views-matchers"
  s.version     = RSpec::Rails::Views::Matchers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["kucaahbe"]
  s.email       = ["kucaahbe@ukr.net"]
  s.homepage    = ""
  s.summary     = %q{collection of rspec2 views matchers for rails}
  s.description = s.summary

  s.rubyforge_project = "rspec2-rails-views-matchers"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rspec', '>= 2.0.0'
  s.add_dependency 'nokogiri', '~> 1.4.4'
end
