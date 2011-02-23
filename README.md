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

    rendered.should have_tag('form',:with => {:action => user_path, :method => 'post'}) {
      with_tag "input", :with => { :name => "user[email]",    :type => 'email' }
      with_tag "input", :with => { :name => "user[password]", :type => 'password' }
      with_tag "input", :with => { :name => "user[password_confirmation]", :type => 'password' }
      with_tag "input#special_submit", :count => 1
      without_tag "h1", :text => 'unneeded tag'
      without_tag "p",  :text => /content/i
    }

More info
---------

[On RubyDoc](http://rubydoc.info/gems/rspec2-rails-views-matchers)
