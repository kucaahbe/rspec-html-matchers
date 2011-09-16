Changelog
=========

unreleased(TODO)
----------------

* add description
* add :without to have\_tag?
* ?make possible constructions like:

      rendered.should have(3).tags('div').with(:class => 'some-class').and_content(/some content/)


0.2.0
-----

* a little bit refactoring
- * add html5 inputs
* added message for should\_not
* raise exception when wrong parametres specified(:count and :minimum (or :maximum) simultaneously)
* support all versions of nokogiri since 1.4.4

0.1.6 (nokogiri update)
-----------------------

* updated <strong>nokogiri</strong> to <strong>1.5.0</strong> version, for nokokiri less than 1.5.0 use 0.0.6 release of this gem

0.0.6
-----

* allow for single quotes in content matchers (thanks to [Kelly Felkins](http://github.com/kellyfelkins)).

0.0.5 (trial-trip)
------------------

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
