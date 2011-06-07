Changelog
=========

unreleased(TODO)
----------------

* add message for should\_not
* add description
* raise exception when wrong parametres specified(:count and :minimum simultaneously)
* organize code
* add :without to have\_tag?
* ?make possible constructions like:

      rendered.should have(3).tags('div').with(:class => 'some-class').and_content(/some content/)

0.0.6
-----

* allow for single quotes in content matchers (thanks to [Kelly Felkins](http://github.com/kellyfelkins)).

0.0.5 (trial-trip)
----------------------

* added some experimental matchers:
  * have\_form
    * with\_hidden\_field
    * with\_text\_field
    * with\_password\_field
    * with\_file\_field?
    * with\_text\_area
    * with\_check\_box
    * with\_radio\_button
    * with\_select
      * with\_option
    * with\_submit

0.0.4 (bugfix)
--------------

* additional parameters(:count,:text,:with) rely on each other to match what exactly tester want to match([link to comment](https://github.com/kucaahbe/rspec2-rails-views-matchers/issues#issue/2/comment/848775))

0.0.3
-----

* now following will work:

      rendered.should have_tag('div') do
        with_tag('p')
      end

* tags can be specified via symbol
* classes can be specified via array or string(class-names separated by spaces), so following will work:

      '<div class="one two">'.should have_tag('div', :with => { :class => ['two', 'one'] })
      '<div class="one two">'.should have_tag('div', :with => { :class => 'two one' })

0.0.2
------

* documented source code
* added changelog

0.0.1
------

* all needed options and error messages
