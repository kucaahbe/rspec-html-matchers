require 'spec_helper'

describe 'have_tag' do

  context "through css selector" do

    before :each do
      render_html <<HTML
<div>
  some content
  <div id="div">some other div</div>
  <p class="paragraph">la<strong>lala</strong></p>
</div>
<form id="some_form">
  <input id="search" type="text" />
  <input type="submit" value="Save" />
</form>
HTML
    end

    it "should find tags" do
      rendered.should have_tag('div')
      rendered.should have_tag('div#div')
      rendered.should have_tag('p.paragraph')
      rendered.should have_tag('div p strong')
    end

    it "should not find tags" do
      rendered.should_not have_tag('span')
      rendered.should_not have_tag('span#id')
      rendered.should_not have_tag('span#class')
    end

    it "should not find tags and display appropriate message" do
      expect { rendered.should have_tag('span') }.should raise_error(
	RSpec::Expectations::ExpectationNotMetError,
	%Q{expected following:\n#{rendered}\nto include //span}
      )
      expect { rendered.should have_tag('span#some_id') }.should raise_error(
	RSpec::Expectations::ExpectationNotMetError,
	%Q{expected following:\n#{rendered}\nto include //span[@id = 'some_id']}
      )
      expect { rendered.should have_tag('span.some_class') }.should raise_error(
	RSpec::Expectations::ExpectationNotMetError,
	%Q{expected following:\n#{rendered}\nto include //span[contains(concat(' ', @class, ' '), ' some_class ')]}
      )
    end

    context "with additional HTML attributes(:with option)" do

      it "should find tags" do
	rendered.should have_tag('input#search',:with => {:type => "text"})
	rendered.should have_tag('input',:with => {:type => "submit", :value => "Save"})
      end

      it "should not find tags" do
	rendered.should_not have_tag('input#search',:with => {:type => "some_other_type"})
      end

      it "should not find tags and display appropriate message" do
	expect { rendered.should have_tag('input#search',:with => {:type => "some_other_type"}) }.should raise_error(
	RSpec::Expectations::ExpectationNotMetError,
	%Q{expected following:\n#{rendered}\nto include //input[@id = 'search' and @type = "some_other_type"]}
	)
      end

    end

  end

  context "with count specified" do

    before :each do
      render_html <<HTML
<p>tag one</p>
<p>tag two</p>
<p>tag three</p>
HTML
    end

    it "should find tags" do
      rendered.should have_tag('p', :count => 3)
      rendered.should have_tag('p', :count => 2..3)
      rendered.should have_tag('p',:count => '>2')
      rendered.should have_tag('p',:count => '>=3')
      rendered.should have_tag('p',:count => '<5')
      rendered.should have_tag('p',:count => '<=3')
    end

    it "should not find tags" do
      pending :TODO
    end

    it "should not find tags and display appropriate message" do
      pending :TODO
    end

  end

  context "with content specified" do

    before :each do
      render_html <<HTML
<div>sample text</div>
<p>one </p>
<p> two</p>
<p> three </p>
HTML
    end

    it "should find tags" do
      rendered.should have_tag('div', :text => 'sample text')
      rendered.should have_tag('p',   :text => 'one'        )
      rendered.should have_tag('div', :text => /sample/     )
    end

    it "should not find tags" do
      rendered.should_not have_tag('p',      :text => 'text does not present')
      rendered.should_not have_tag('strong', :text => 'text does not present')
      rendered.should_not have_tag('p',      :text => /text does not present/)
      rendered.should_not have_tag('strong', :text => /text does not present/)
    end

    it "should not find tags and display appropriate message" do
      pending :TODO
    end

  end

  context "nested matching:" do

    it "should find tags inside other tag" do
      render_html <<HTML
<ol>
  <li>list item 1</li>
  <li>list item 2</li>
  <li>list item 3</li>
</ol>
HTML

      rendered.should have_tag('ol') {
        with_tag('li', :text => 'list item 1')
        with_tag('li', :text => 'list item 2')
        with_tag('li', :text => 'list item 3')
	without_tag('div')
      }
    end

  end

end
