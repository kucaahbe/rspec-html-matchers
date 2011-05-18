Test views, be true! :)
=======================

[![Build Status](http://travis-ci.org/kucaahbe/rspec2-rails-views-matchers.png)](http://travis-ci.org/kucaahbe/rspec2-rails-views-matchers)

[![Mikhalok](http://investigator.org.ua/wp-content/uploads/01_500_liapis_powe-300x192.jpg)](http://www.myspace.com/lyapis "Lyapis Trubetskoy ska-punk band")

Why?
===

* you need to test some complex views
* and you want to use rspec2
* and assert\_select seems is something strange to you
* [rspec-rails](http://github.com/rspec/rspec-rails) for some reason does not provide instruments for testing views
* you need user-firendly output in error messages

Install
-------

add to your Gemfile(in group :test :) ):

    gem 'rspec2-rails-views-matchers'

Usage
-----

some examples:

    rendered.should have_tag('form',:with => {:action => user_path, :method => 'post'}) do
      with_tag "input", :with => { :name => "user[email]",    :type => 'email' }
      with_tag "input#special_submit", :count => 1
      without_tag "h1", :text => 'unneeded tag'
      without_tag "p",  :text => /content/i
    end

More info
---------

You can find [on RubyDoc](http://rubydoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers), take a look at {RSpec::Matchers#have\_tag have\_tag} method.

Also, please read {file:docs/CHANGELOG.md CHANGELOG}, it might be helpful.
