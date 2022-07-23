# -*- encoding: utf-8 -*-
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rspec-html-matchers/version'
ruby_version = Gem::Version.new(RUBY_VERSION)

Gem::Specification.new do |s|
  s.name        = 'rspec-html-matchers'
  s.version     = RSpecHtmlMatchers::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['kucaahbe']
  s.email       = ['kucaahbe@ukr.net', 'randoum@gmail.com']
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/kucaahbe/rspec-html-matchers'
  s.summary     = "Nokogiri based 'have_tag' and 'with_tag' matchers for rspec 3 & 4"
  s.description = <<DESC
#{s.summary}. Does not depend on assert_select matcher, provides useful error messages.
DESC

  s.files            = Dir['lib/**/*.rb']
  s.test_files       = Dir['{spec,features}/**/*.{rb,feature}']
  s.require_path     = 'lib'
  s.extra_rdoc_files = ['README.md', 'CHANGELOG.md']

  # ruby support is tied to rspec & nokogiri gems:
  s.required_ruby_version = '>= 1.8.7'

  s.add_runtime_dependency 'rspec',    '>= 3.0.0.a', '< 5'
  s.add_runtime_dependency 'nokogiri', '~> 1'

  # cucumber tests:
  # for older rubies there is not much sense to run cucumber tests,
  # as some of gems (specifically selenium-webdriver and webdrivers)
  # have issues either installing or working properly
  if ruby_version >= Gem::Version.new('2')
    s.add_development_dependency 'cucumber', '~> 1'
    s.add_development_dependency 'capybara', '~> 2'
    s.add_development_dependency 'sinatra',  '~> 1'
    s.add_development_dependency 'selenium-webdriver', '~> 3'
    s.add_development_dependency 'webdrivers',
      (ruby_version >= Gem::Version.new('2.3') ? '~> 4' : '<= 3.8.1')
  end

  s.add_development_dependency 'simplecov',          '~> 0'
  s.add_development_dependency 'rake',               '~> 10'
  s.add_development_dependency 'travis-lint',        '~> 1'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rubocop', '= 0.76.0' if ruby_version >= Gem::Version.new('2.3')

  s.add_development_dependency 'ruby-debug' if RUBY_PLATFORM == 'java'
end
