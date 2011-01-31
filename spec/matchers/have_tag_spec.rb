require 'spec_helper'

describe 'have_tag' do

  context "simple matching:" do

    it "should find tag by css selector" do
      render_html <<HTML
      <div>
        some content
	<div id="div">some other div</div>
      </div>
      <p class="paragraph">la<strong>lala</strong></p>
HTML
      rendered.should have_tag('div')
      rendered.should have_tag('div#div')
      rendered.should have_tag('p.paragraph')
    end

    it "should not find tag by css selector" do
      render_html "<p>some text<p>"
      rendered.should_not have_tag('strong')
      expect { rendered.should have_tag('strong') }.should raise_error(
	RSpec::Expectations::ExpectationNotMetError,
	%Q{expected following:\n#{rendered}\nto include //strong}
      )
      expect { rendered.should have_tag('strong#some_id') }.should raise_error(
	RSpec::Expectations::ExpectationNotMetError,
	%Q{expected following:\n#{rendered}\nto include //strong[@id = 'some_id']}
      )
    end

    it "should find tags with count specified" do
      render_html <<HTML
      <p>tag one</p>
      <p>tag two</p>
      <p>tag three</p>
HTML

      rendered.should have_tag('p', :count => 3)
      rendered.should have_tag('p', :count => 2..3)

      rendered.should have_tag('p',:count => '>2')
      rendered.should have_tag('p',:count => '>=3')
      rendered.should have_tag('p',:count => '<5')
      rendered.should have_tag('p',:count => '<=3')

      rendered.should_not have_tag('p', :count => 2)
      rendered.should_not have_tag('p', :count => 5)
      rendered.should_not have_tag('p', :count => 2..5)
    end

    it "should find text" do
      pending
      rendered.should have_tag('div', :text => 'sample text')
      rendered.should have_tag('p', :text => 'one')
      rendered.should have_tag('p', :text => 'two')
      rendered.should have_tag('p', :text => 'three')
      rendered.should have_tag('div', :text => /sample/)

      rendered.should_not have_tag('p', :text => 'text does not present')
      rendered.should_not have_tag('strong', :text => 'text does not present')

      rendered.should_not have_tag('p', :text => /text does not present/)
      rendered.should_not have_tag('strong', :text => /text does not present/)
    end

    it "should match html attributes" do
      pending
    end

  end

  context "nested matching:" do

    #???????????????????????
    #how here?
    it "should find tags inside other tag" do
      rendered.should have_tag('ol') {
        with_tag('li', :text => 'list item 1')
        with_tag('li', :text => 'list item 2')
        with_tag('li', :text => 'list item 3')
      }
    end

    it "should not find tags inside other tag" do
      rendered.should have_tag('ol') {
	without_tag('div')
      }
    end

  end

end
