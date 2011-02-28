changelog
=========

unreleased(TODO)
----------------

* add message for should\_not
* add description
* raise exception when wrong parametres specified(:count and :minimum simultaneously)
* organize code
* add more matchers(have\_form,with\_input)?

0.0.3
-----

* now following will work:

>     rendered.should have_tag('div') do
>       with_tag('p')
>     end

* tags can be specified via symbol
* classes can be specified via array
* attributes can be specified via regexp

0.0.2
------

* documented source code
* added changelog

0.0.1
------

* all needed options and error messages
