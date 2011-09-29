# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rspec2-rails-views-matchers"
  s.version     = '0.2.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["kucaahbe"]
  s.email       = ["kucaahbe@ukr.net"]
  s.homepage    = "http://github.com/kucaahbe/rspec2-rails-views-matchers"
  s.summary     = %q{Nokogiri based 'have_tag' and 'with_tag' matchers for rspec 2.x.x}
  s.description = <<DESC
#{s.summary}. Does not depend on assert_select matcher, provides useful error messages.
DESC

  s.rubyforge_project = "rspec2-rails-views-matchers"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'rspec', '>= 2.0.0'
  s.add_dependency 'nokogiri', '>= 1.4.4'

  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rake'
end
