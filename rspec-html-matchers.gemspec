# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'rspec-html-matchers'
  s.version     = '0.7.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['kucaahbe']
  s.email       = ['kucaahbe@ukr.net']
  s.license     = 'MIT'
  s.homepage    = 'http://github.com/kucaahbe/rspec-html-matchers'
  s.summary     = %q{Nokogiri based 'have_tag' and 'with_tag' matchers for rspec 2.x.x}
  s.description = <<DESC
#{s.summary}. Does not depend on assert_select matcher, provides useful error messages.
DESC

  s.rubyforge_project = 'rspec-html-matchers'

  s.files            = Dir['lib/**/*.rb']
  s.test_files       = Dir['{spec,features}/**/*.{rb,feature}']
  s.require_path     = 'lib'
  s.extra_rdoc_files = ['README.md','CHANGELOG.md']

  # since 2.11.0 introduced new expect().to syntax
  s.add_runtime_dependency 'rspec',    '~> 3'
  s.add_runtime_dependency 'nokogiri', '~> 1'

  s.add_development_dependency 'simplecov',          '~> 0'
  s.add_development_dependency 'cucumber',           '~> 1'
  s.add_development_dependency 'capybara',           '~> 2'
  s.add_development_dependency 'selenium-webdriver', '~> 2'
  s.add_development_dependency 'sinatra',            '~> 1'
  s.add_development_dependency 'rake',               '~> 10'
  s.add_development_dependency 'travis-lint',        '~> 1'
  if RUBY_ENGINE=='ruby' and RUBY_VERSION < '2.1.1'
    s.add_development_dependency 'debugger',         '~> 1'
  end
end
