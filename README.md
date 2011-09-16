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

Instructions for [installing nokogiri here.](http://nokogiri.org/tutorials/installing_nokogiri.html)

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

- [have\_form](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:have_form)
- [have\_tag](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:have_tag)
- [with\_checkbox](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_checkbox)
- [with\_email\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_email_field)
- [with\_file\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_file_field)
- [with\_hidden\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_hidden_field)
- [with\_option](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_option)
- [with\_password_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_password_field)
- [with\_radio\_button](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_radio_button)
- [with\_select](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_select)
- [with\_submit](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_submit)
- [with\_text\_area](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_text_area)
- [with\_text\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_text_field)
- [with\_url\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_url_field)
- [with\_number\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_number_field)
- [with\_range\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_range_field)
- [with\_date\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_date_field)
- [with\_search\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_search_field)
- [with\_color\_field](http://rdoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers:with_color_field)

and of course you can use <strong>without_</strong>matchers(see documentation).

More info
---------

You can find [on RubyDoc](http://rubydoc.info/github/kucaahbe/rspec2-rails-views-matchers/master/RSpec/Matchers), take a look at {RSpec::Matchers#have\_tag have\_tag} method.

Also, please read {file:CHANGELOG.md CHANGELOG}, it might be helpful.

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

License
=======

This gem is released under the MIT license.
