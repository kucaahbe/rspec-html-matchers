require 'spec_helper'

describe 'have_tag' do

  it "should have message for should_not"
  it "should have #description method"

  context "through css selector" do

    before :each do
      render_html <<HTML
<div class="class-one class-two">
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
      rendered.should have_tag(:div)
      rendered.should have_tag('div#div')
      rendered.should have_tag('p.paragraph')
      rendered.should have_tag('div p strong')
    end

    it "should not find tags" do
      rendered.should_not have_tag('span')
      rendered.should_not have_tag(:span)
      rendered.should_not have_tag('span#id')
      rendered.should_not have_tag('span#class')
      rendered.should_not have_tag('div div span')
    end

    it "should not find tags and display appropriate message" do
      expect { rendered.should have_tag('span') }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at least 1 element matching "span", found 0.}
      )
      expect { rendered.should have_tag('span#some_id') }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at least 1 element matching "span#some_id", found 0.}
      )
      expect { rendered.should have_tag('span.some_class') }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at least 1 element matching "span.some_class", found 0.}
      )
    end

    context "with additional HTML attributes(:with option)" do

      it "should find tags" do
	rendered.should have_tag('input#search',:with => {:type => "text"})
	rendered.should have_tag(:input ,:with => {:type => "submit", :value => "Save"})
      end

      it "should find tags that have classes specified via array(or string)" do
	rendered.should have_tag('div',:with => {:class => %w(class-one class-two)})
	rendered.should have_tag('div',:with => {:class => 'class-two class-one'})
      end

      it "should not find tags that have classes specified via array" do
	rendered.should_not have_tag('div',:with => {:class => %w(class-other class-two)})
      end

      it "should not find tags that have classes specified via array and display appropriate message" do
	expect do
	  rendered.should have_tag('div',:with => {:class => %w(class-other class-two)})
	end.should raise_spec_error(
	  %Q{expected following:\n#{rendered}\nto have at least 1 element matching "div.class-other.class-two", found 0.}
	)
	expect do
	  rendered.should have_tag('div',:with => {:class => 'class-other class-two'})
	end.should raise_spec_error(
	  %Q{expected following:\n#{rendered}\nto have at least 1 element matching "div.class-other.class-two", found 0.}
	)
      end

      it "should not find tags" do
	rendered.should_not have_tag('input#search',:with => {:type => "some_other_type"})
	rendered.should_not have_tag(:input, :with => {:type => "some_other_type"})
      end

      it "should not find tags and display appropriate message" do
	expect { rendered.should have_tag('input#search',:with => {:type => "some_other_type"}) }.should raise_spec_error(
	  %Q{expected following:\n#{rendered}\nto have at least 1 element matching "input#search[type='some_other_type']", found 0.}
	)
      end

    end

  end

  context "by count" do

    before :each do
      render_html <<HTML
<p>tag one</p>
<p>tag two</p>
<p>tag three</p>
HTML
    end

    it "should find tags" do
      rendered.should have_tag('p', :count    => 3)
      rendered.should have_tag('p', :count => 2..3)
    end

    it "should find tags when :minimum specified" do
      rendered.should have_tag('p', :min      => 3)
      rendered.should have_tag('p', :minimum  => 2)
    end

    it "should find tags when :maximum specified" do
      rendered.should have_tag('p', :max      => 4)
      rendered.should have_tag('p', :maximum  => 3)
    end

    it "should not find tags(with :count, :minimum or :maximum specified)" do
      rendered.should_not have_tag('p', :count   => 10)
      rendered.should_not have_tag('p', :count => 4..8)
      rendered.should_not have_tag('p', :min     => 11)
      rendered.should_not have_tag('p', :minimum => 10)
      rendered.should_not have_tag('p', :max     => 2)
      rendered.should_not have_tag('p', :maximum => 2)
    end

    it "should not find tags and display appropriate message(with :count)" do
      expect { rendered.should have_tag('p', :count => 10) }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have 10 element(s) matching "p", found 3.}
	)

      expect { rendered.should have_tag('p', :count => 4..8) }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at least 4 and at most 8 element(s) matching "p", found 3.}
	)
    end

    it "should not find tags and display appropriate message(with :minimum)" do
      expect { rendered.should have_tag('p', :min => 100) }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at least 100 element(s) matching "p", found 3.}
	)
      expect { rendered.should have_tag('p', :minimum => 100) }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at least 100 element(s) matching "p", found 3.}
	)
    end

    it "should not find tags and display appropriate message(with :maximum)" do
      expect { rendered.should have_tag('p', :max => 2) }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at most 2 element(s) matching "p", found 3.}
	)
      expect { rendered.should have_tag('p', :maximum => 2) }.should raise_spec_error(
	%Q{expected following:\n#{rendered}\nto have at most 2 element(s) matching "p", found 3.}
	)
    end

    it "should raise error when wrong params specified" do
      pending(:TODO)
      wrong_params_error_msg_1 = 'TODO1'
      expect { rendered.should have_tag('div', :count => 2, :minimum => 1 ) }.should raise_error(wrong_params_error_msg_1)
      expect { rendered.should have_tag('div', :count => 2, :min => 1 )     }.should raise_error(wrong_params_error_msg_1)
      expect { rendered.should have_tag('div', :count => 2, :maximum => 1 ) }.should raise_error(wrong_params_error_msg_1)
      expect { rendered.should have_tag('div', :count => 2, :max => 1 )     }.should raise_error(wrong_params_error_msg_1)

      wrong_params_error_msg_2 = 'TODO2'
      expect { rendered.should have_tag('div', :minimum => 2, :maximum => 1 ) }.should raise_error(wrong_params_error_msg_2)

      [ 4..1, -2..6, 'a'..'z', 3..-9 ].each do |range|
	expect { rendered.should have_tag('div', :count => range ) }.should raise_error("Your :count range(#{range.to_s}) has no sence!")
      end
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
      rendered.should have_tag('p',   :text => 'one '       )
      rendered.should have_tag('div', :text => /SAMPLE/i    )
    end

    it "should not find tags" do
      rendered.should_not have_tag('p',      :text => 'text does not present')
      rendered.should_not have_tag('strong', :text => 'text does not present')
      rendered.should_not have_tag('p',      :text => /text does not present/)
      rendered.should_not have_tag('strong', :text => /text does not present/)
    end

    it "should not find tags and display appropriate message" do
      # TODO make diffable,maybe...
      expect { rendered.should have_tag('div', :text => 'SAMPLE text') }.should raise_spec_error(
	%Q{"SAMPLE text" expected within "div" in following template:\n#{rendered}}
	)
      expect { rendered.should have_tag('div', :text => /SAMPLE tekzt/i) }.should raise_spec_error(
	%Q{/SAMPLE tekzt/i regexp expected within "div" in following template:\n#{rendered}}
	)
    end

  end

  context "mixed matching", :wip => true do

    before :each do
      render_html <<HTML
<table>
  <tr>
    <td>user_1</td>
    <td id="other-special">user_2</td>
    <td>user_3</td>
  </tr>
  <tr>
    <td>a</td>
    <td id="special">a</td>
    <td>a</td>
  </tr>
</table>

<div class="one">text</div>
<div class="one">text</div>
<div class="one">text</div>
<div class="one">text bla</div>
<div class="one">content bla</div>
<div class="one">content</div>
<div class="two">content bla</div>
<div class="two">content</div>
<div class="two">text</div>
HTML
    end

    it "should find tags by count and exact content" do
      rendered.should have_tag("td", :text => 'a', :count => 3)
    end

    it "should find tags by count and rough content(regexp)" do
      rendered.should have_tag("td", :text => /user/, :count => 3)
    end

    it "should find tags with exact content and additional attributes" do
      rendered.should have_tag("td", :text => 'a', :with => { :id => "special" })
      rendered.should_not have_tag("td", :text => 'a', :with => { :id => "other-special" })
    end

    it "should find tags with rough content and additional attributes" do
      rendered.should have_tag("td", :text => /user/, :with => { :id => "other-special" })
      rendered.should_not have_tag("td", :text => /user/, :with => { :id => "special" })
    end

    it "should find tags with count and additional attributes" do
      rendered.should have_tag("div", :with => { :class => "one" }, :count => 6)
      rendered.should have_tag("div", :with => { :class => "two" }, :count => 3)
    end

    it "should find tags with count, exact text and additional attributes" do
      rendered.should have_tag("div", :with => { :class => "one" }, :count => 3, :text => 'text')
      rendered.should_not have_tag("div", :with => { :class => "one" }, :count => 5, :text => 'text')
      rendered.should_not have_tag("div", :with => { :class => "one" }, :count => 3, :text => 'other text')
      rendered.should_not have_tag("div", :with => { :class => "two" }, :count => 3, :text => 'text')
    end

    it "should find tags with count, regexp text and additional attributes" do
      rendered.should have_tag("div", :with => { :class => "one" }, :count => 2, :text => /bla/)
      rendered.should have_tag("div", :with => { :class => "two" }, :count => 1, :text => /bla/)
      rendered.should_not have_tag("div", :with => { :class => "one" }, :count => 5, :text => /bla/)
      rendered.should_not have_tag("div", :with => { :class => "one" }, :count => 6, :text => /other bla/)
    end

  end

  context "nested matching:" do
    before :each do
      @ordered_list =<<OL
    <ol class="menu">
      <li>list item 1</li>
      <li>list item 2</li>
      <li>list item 3</li>
    </ol>
OL
      render_html <<HTML
<html>
  <body>
#{@ordered_list}
  </body>
</html>
HTML
    end

    it "should find tags" do
      rendered.should have_tag('ol') {
	with_tag('li', :text  => 'list item 1')
	with_tag('li', :text  => 'list item 2')
	with_tag('li', :text  => 'list item 3')
	with_tag('li', :count => 3)
	with_tag('li', :count => 2..3)
	with_tag('li', :min   => 2)
	with_tag('li', :max   => 6)
      }
    end

    it "should not find tags" do
      rendered.should have_tag('ol') {
	without_tag('div')
	without_tag('li', :count => 2)
	without_tag('li', :count => 4..8)
	without_tag('li', :min => 100)
	without_tag('li', :max => 2)
	without_tag('li', :text => 'blabla')
	without_tag('li', :text => /list item (?!\d)/)
      }
    end

    it "should handle do; end" do
      expect do
	rendered.should have_tag('ol') do
	  with_tag('div')
	end
      end.should raise_spec_error(/have at least 1 element matching "div", found 0/)
    end

    it "should not find tags and display appropriate message" do
      ordered_list_regexp = @ordered_list.gsub(/(\n?\s{2,}|\n\s?)/,'\n*\s*')
      expect {
	rendered.should have_tag('ol') { with_tag('li'); with_tag('div') }
      }.should raise_spec_error(/expected following:#{ordered_list_regexp}to have at least 1 element matching "div", found 0/)

      expect {
	rendered.should have_tag('ol') { with_tag('li'); with_tag('li', :count => 10) }
      }.should raise_spec_error(/expected following:#{ordered_list_regexp}to have 10 element\(s\) matching "li", found 3/)

      expect {
	rendered.should have_tag('ol') { with_tag('li'); with_tag('li', :text => /SAMPLE text/i) }
      }.should raise_spec_error(/\/SAMPLE text\/i regexp expected within "li" in following template:#{ordered_list_regexp}/)
    end

  end

end
