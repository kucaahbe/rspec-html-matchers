Test views, be true! :) [![Build Status](http://travis-ci.org/kucaahbe/rspec2-rails-views-matchers.png)](http://travis-ci.org/kucaahbe/rspec2-rails-views-matchers)
=======================

[![Mikhalok](https://github.com/kucaahbe/rspec2-rails-views-matchers/raw/master/mikhalok.jpg)](http://www.myspace.com/lyapis "Lyapis Trubetskoy ska-punk band")

Why?
===

* you need to test some complex views
* and you want to use rspec2
* and assert\_select seems is something strange to you
* have_tag in [rspec-rails](http://github.com/rspec/rspec-rails) are deprecated now
* you need user-firendly output in error messages

Being true
==========

Install
-------

add to your Gemfile(in group :test :) ):

    gem 'rspec2-rails-views-matchers'

TODO install nokogiri link

Usage
-----

some examples:

    rendered.should have_tag('form',:with => {:action => user_path, :method => 'post'}) do
      with_tag "input", :with => { :name => "user[email]",    :type => 'email' }
      with_tag "input#special_submit", :count => 1
      without_tag "h1", :text => 'unneeded tag'
      without_tag "p",  :text => /content/i
    end

List of all defined matchers ("form" matchers)
-----------------------------------------------------

TODO add all
- [have_form](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:have_form)
- [with_checkbox](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_checkbox)
- [with_file_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_file_field)
- [with_hidden_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_hidden_field)
- [with_option](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_option)
- [with_password_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_password_field)
- [with_radio_button](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_radio_button)
- [with_select](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_select)
- [with_submit](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_submit)
- [with_text_area](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_text_area)
- [with_text_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_text_field)

and of course you can use <strong>without_</strong>matchers(TODO CHANGEME)

More info
---------

You can find [on RubyDoc](http://rubydoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers), take a look at {RSpec::Matchers#have\_tag have\_tag} method.

Also, please read {file:docs/CHANGELOG.md CHANGELOG}, it might be helpful.

Contribution
============

1. fork
2. add tests for feature
3. write implementation
4. send pull request

Contributors
============

- [Kelly Felkins](http://github.com/kellyfelkins)
- [Ryan Wilcox](http://github.com/rwilcox)

TODO LICENSE
