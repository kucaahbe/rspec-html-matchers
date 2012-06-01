Test views, be true! :) [![Build Status](http://travis-ci.org/kucaahbe/rspec-html-matchers.png)](http://travis-ci.org/kucaahbe/rspec-html-matchers)
=======================

[![Mikhalok](https://github.com/kucaahbe/rspec-html-matchers/raw/master/mikhalok.jpg)](http://www.myspace.com/lyapis "Lyapis Trubetskoy ska-punk band")

Why?
===

* you need to test some complex views
* and you want to use RSpec2
* and assert\_select seems is something strange to you
* have_tag in [rspec-rails](http://github.com/rspec/rspec-rails) are deprecated now
* you need a user-firendly output in your error messages

Being true
==========

Install
-------

Add to your Gemfile (in the :test group :) ):

```ruby
group :test do
  gem 'rspec-html-matchers'
end
```

Instructions for [installing Nokogiri](http://nokogiri.org/tutorials/installing_nokogiri.html).

Usage
-----

Simple example:

```ruby
view=<<-HTML
<h1>Simple Form</h1>
<form action="/users" method="post">
<p>
  <input type="email" name="user[email]" />
</p>
<p>
  <input type="submit" id="special_submit" />
</p>
</form>
HTML

view.should have_tag('form', :with => { :action => '/users', :method => 'post' }) do
  with_tag "input", :with => { :name => "user[email]", :type => 'email' }
  with_tag "input#special_submit", :count => 1
  without_tag "h1", :text => 'unneeded tag'
  without_tag "p",  :text => /content/i
end
```

Examples with more description:

* tag matching (matches one or more tags):

```ruby
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag('p')
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag(:p)
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag('p#qwerty')
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag('p.qwe.rty')

'<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>'.should have_tag('p strong')
'<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>'.should have_tag('p#qwerty strong')
'<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>'.should have_tag('p.qwe.rty strong')
# or
'<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>'.should have_tag('p') do
  with_tag('strong')
end
'<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>'.should have_tag('p#qwerty') do
  with_tag('strong')
end
'<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>'.should have_tag('p.qwe.rty') do
  with_tag('strong')
end
```

* special case: classes matching:

```ruby
# all of this are equivalent:
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag('p', :with => { :class => 'qwe rty' })
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag('p', :with => { :class => 'rty qwe' })
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag('p', :with => { :class => ['rty', 'qwe'] })
'<p class="qwe rty" id="qwerty">Paragraph</p>'.should have_tag('p', :with => { :class => ['qwe', 'rty'] })
```

usage with capybara and cucumber:

    page.should have_tag( ... )

where `page` is an instance of Capybara::Session

Also included special matchers for form inputs:
-----------------------------------------------

- [have\_form](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:have_form)
- [with\_checkbox](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_checkbox)
- [with\_email\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_email_field)
- [with\_file\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_file_field)
- [with\_hidden\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_hidden_field)
- [with\_option](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_option)
- [with\_password_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_password_field)
- [with\_radio\_button](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_radio_button)
- [with\_button](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_button)
- [with\_select](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_select)
- [with\_submit](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_submit)
- [with\_text\_area](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_text_area)
- [with\_text\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_text_field)
- [with\_url\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_url_field)
- [with\_number\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_number_field)
- [with\_range\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_range_field)
- [with\_date\_field](http://rdoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers:with_date_field)

and of course you can use the `without_` matchers (see the documentation).

More info
---------

You can find more on [RubyDoc](http://rubydoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers), take a look at {RSpec::Matchers#have\_tag have\_tag} method.

Also, please read {file:CHANGELOG.md CHANGELOG}, it might be helpful.

Contribution
============

1. Fork the repository
2. Add tests for your feature
3. Write the code
4. Send a pull request

Contributors
============

- [Kelly Felkins](http://github.com/kellyfelkins)
- [Ryan Wilcox](http://github.com/rwilcox)
- [Simon Schoeters](https://github.com/cimm)
- [Felix Tjandrawibawa](https://github.com/cemenghttps://github.com/cemeng)
- [Szymon Przybył](https://github.com/apocalyptiq)
- [Howard Wilson](https://github.com/watsonbox)

MIT Licensed
============

Copyright (c) 2011-2012 Dmitrij Mjakotnyi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
