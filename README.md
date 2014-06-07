rspec-html-matchers
===================

[RSpec 3](https://www.relishapp.com/rspec) matchers for testing your html (for [RSpec 2](https://www.relishapp.com/rspec/rspec-core/v/2-99/docs) use 0.5.x version).

[![Gem Version](https://badge.fury.io/rb/rspec-html-matchers.png)](http://badge.fury.io/rb/rspec-html-matchers)
[![Build Status](https://travis-ci.org/kucaahbe/rspec-html-matchers.png)](http://travis-ci.org/kucaahbe/rspec-html-matchers)

Goals
-----

* for testing **complicated** html output, for simple matching consider use:
  * [assert_select](http://api.rubyonrails.org/classes/ActionDispatch/Assertions/SelectorAssertions.html#method-i-assert_select)
  * [matchers provided out of the box in rspec-rails](https://www.relishapp.com/rspec/rspec-rails/v/2-11/docs/view-specs/view-spec)
  * [matchers provided by capybara](http://rdoc.info/github/jnicklas/capybara/Capybara/Node/Matchers)
* developer-firendly output in error messages
* built on top of [nokogiri](nokogiri.org)
* has support for [capybara](https://github.com/jnicklas/capybara), see below
* syntax is similar to [have_tag](http://old.rspec.info/rails/writing/views.html) matcher from old-school rspec-rails, but with own syntactic sugar
* framework agnostic, as input should be String(or capybara's page, see below)

Install
-------

Add to your Gemfile in the `:test` group:

```ruby
gem 'rspec-html-matchers'
```

as this gem requires **nokogiri**, here [instructions for installing it](http://nokogiri.org/tutorials/installing_nokogiri.html).

Usage
-----

so perharps your code produces following output:

```html
<h1>Simple Form</h1>
<form action="/users" method="post">
<p>
  <input type="email" name="user[email]" />
</p>
<p>
  <input type="submit" id="special_submit" />
</p>
</form>
```

so you test it with following:

```ruby
expect(rendered).to have_tag('form', :with => { :action => '/users', :method => 'post' }) do
  with_tag "input", :with => { :name => "user[email]", :type => 'email' }
  with_tag "input#special_submit", :count => 1
  without_tag "h1", :text => 'unneeded tag'
  without_tag "p",  :text => /content/i
end
```

Example about should be self-descriptive, but if not refer to [have_tag](http://rdoc.info/github/kucaahbe/rspec-html-matchers/RSpec/Matchers:have_tag) documentation

Input could be any html string. Let's take a look at these examples:

* matching tags by css:

  ```ruby
  # simple examples:
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p')
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag(:p)
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p#qwerty')
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p.qwe.rty')
  # more complicated examples:
  expect('<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>').to have_tag('p strong')
  expect('<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>').to have_tag('p#qwerty strong')
  expect('<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>').to have_tag('p.qwe.rty strong')
  # or you can use another syntax for examples above
  expect('<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>').to have_tag('p') do
    with_tag('strong')
  end
  expect('<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>').to have_tag('p#qwerty') do
    with_tag('strong')
  end
  expect('<p class="qwe rty" id="qwerty"><strong>Para</strong>graph</p>').to have_tag('p.qwe.rty') do
    with_tag('strong')
  end
  ```

* special case for classes matching:

  ```ruby
  # all of this are equivalent:
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :with => { :class => 'qwe rty' })
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :with => { :class => 'rty qwe' })
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :with => { :class => ['rty', 'qwe'] })
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :with => { :class => ['qwe', 'rty'] })
  ```

  The same works with `:without`:

  ```ruby
  # all of this are equivalent:
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :without => { :class => 'qwe rty' })
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :without => { :class => 'rty qwe' })
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :without => { :class => ['rty', 'qwe'] })
  expect('<p class="qwe rty" id="qwerty">Paragraph</p>').to have_tag('p', :without => { :class => ['qwe', 'rty'] })
  ```

* content matching:

  ```ruby
  expect('<p> Some content&nbsphere</p>').to have_tag('p', :text => ' Some content here')
  # or
  expect('<p> Some content&nbsphere</p>').to have_tag('p') do
    with_text ' Some content here'
  end

  expect('<p> Some content&nbsphere</p>').to have_tag('p', :text => /Some content here/)
  # or
  expect('<p> Some content&nbsphere</p>').to have_tag('p') do
    with_text /Some content here/
  end

  # mymock.text == 'Some content here'
  expect('<p> Some content&nbsphere</p>').to have_tag('p', :content => mymock.text)
  # or
  expect('<p> Some content&nbsphere</p>').to have_tag('p') do
    with_content mymock.text
  end
  ```

* usage with capybara and cucumber:

  ```ruby
  expect(page).to have_tag( ... )
  ```

where `page` is an instance of Capybara::Session

* also included shorthand matchers for form inputs:

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

### rspec 1 partial backwards compatibility:

you can match:

```ruby
expect(response).to have_tag('div', 'expected content')
expect(response).to have_tag('div', /regexp matching expected content/)
```

[RSpec 1 `have_tag` documentation](http://old.rspec.info/rails/writing/views.html)

More info
---------

You can find more on [RubyDoc](http://rubydoc.info/github/kucaahbe/rspec-html-matchers/master/RSpec/Matchers), take a look at [have_tag](http://rdoc.info/github/kucaahbe/rspec-html-matchers/RSpec/Matchers#have_tag-instance_method) method.

Also, please read [CHANGELOG](https://github.com/kucaahbe/rspec-html-matchers/blob/master/CHANGELOG.md), it might be helpful.

Contribution
============

1. Fork the repository
2. Add tests for your feature
3. Write the code
4. Add documentation for your contribution
5. Send a pull request

Contributors
============

- [Kelly Felkins](http://github.com/kellyfelkins)
- [Ryan Wilcox](http://github.com/rwilcox)
- [Simon Schoeters](https://github.com/cimm)
- [Felix Tjandrawibawa](https://github.com/cemenghttps://github.com/cemeng)
- [Szymon Przybył](https://github.com/apocalyptiq)
- [Manuel Meurer](https://github.com/manuelmeurer)

MIT Licensed
============

Copyright (c) 2011-2014 Dmitrij Mjakotnyi

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
