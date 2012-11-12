# encoding: UTF-8
require 'spec_helper'

describe 'have_tag' do
  context "through css selector" do
    asset 'search_and_submit'

    it "should have right description" do
      have_tag('div').description.should == 'have at least 1 element matching "div"'
      have_tag('div.class').description.should == 'have at least 1 element matching "div.class"'
      have_tag('div#id').description.should == 'have at least 1 element matching "div#id"'
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
      expect { rendered.should have_tag('span') }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at least 1 element matching "span", found 0.}
      )
      expect { rendered.should have_tag('span#some_id') }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at least 1 element matching "span#some_id", found 0.}
      )
      expect { rendered.should have_tag('span.some_class') }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at least 1 element matching "span.some_class", found 0.}
      )
    end

    it "should find unexpected tags and display appropriate message" do
      expect { rendered.should_not have_tag('div') }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have element matching "div", found 2.}
      )
      expect { rendered.should_not have_tag('div#div') }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have element matching "div#div", found 1.}
      )
      expect { rendered.should_not have_tag('p.paragraph') }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have element matching "p.paragraph", found 1.}
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
        expect {
          rendered.should have_tag('div',:with => {:class => %w(class-other class-two)})
        }.to raise_spec_error(
          %Q{expected following:\n#{rendered}\nto have at least 1 element matching "div.class-other.class-two", found 0.}
        )
        expect {
          rendered.should have_tag('div',:with => {:class => 'class-other class-two'})
        }.to raise_spec_error(
          %Q{expected following:\n#{rendered}\nto have at least 1 element matching "div.class-other.class-two", found 0.}
        )
      end

      it "should not find tags" do
        rendered.should_not have_tag('input#search',:with => {:type => "some_other_type"})
        rendered.should_not have_tag(:input, :with => {:type => "some_other_type"})
      end

      it "should not find tags and display appropriate message" do
        expect { rendered.should have_tag('input#search',:with => {:type => "some_other_type"}) }.to raise_spec_error(
          %Q{expected following:\n#{rendered}\nto have at least 1 element matching "input#search[type='some_other_type']", found 0.}
        )
      end

      it "should find unexpected tags and display appropriate message" do
        expect { rendered.should_not have_tag('input#search',:with => {:type => "text"}) }.to raise_spec_error(
          %Q{expected following:\n#{rendered}\nto NOT have element matching "input#search[type='text']", found 1.}
        )
      end

    end

  end

  context "by count" do
    asset 'paragraphs'

    it "should have right description" do
      have_tag('div', :count => 100500).description.should == 'have 100500 element(s) matching "div"'
    end

    it "should find tags" do
      rendered.should have_tag('p', :count => 3)
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
      rendered.should_not have_tag('p', :count   => 4..8)
      rendered.should_not have_tag('p', :min     => 11)
      rendered.should_not have_tag('p', :minimum => 10)
      rendered.should_not have_tag('p', :max     => 2)
      rendered.should_not have_tag('p', :maximum => 2)
    end

    it "should not find tags and display appropriate message(with :count)" do
      expect { rendered.should have_tag('p', :count => 10) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have 10 element(s) matching "p", found 3.}
      )

      expect { rendered.should have_tag('p', :count => 4..8) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at least 4 and at most 8 element(s) matching "p", found 3.}
      )
    end

    it "should find unexpected tags and display appropriate message(with :count)" do
      expect { rendered.should_not have_tag('p', :count => 3) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have 3 element(s) matching "p", but found.}
      )

      expect { rendered.should_not have_tag('p', :count => 1..3) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have at least 1 and at most 3 element(s) matching "p", but found 3.}
      )
    end

    it "should not find tags and display appropriate message(with :minimum)" do
      expect { rendered.should have_tag('p', :min => 100) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at least 100 element(s) matching "p", found 3.}
      )
      expect { rendered.should have_tag('p', :minimum => 100) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at least 100 element(s) matching "p", found 3.}
      )
    end

    it "should find unexpected tags and display appropriate message(with :minimum)" do
      expect { rendered.should_not have_tag('p', :min => 2) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have at least 2 element(s) matching "p", but found 3.}
      )
      expect { rendered.should_not have_tag('p', :minimum => 2) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have at least 2 element(s) matching "p", but found 3.}
      )
    end

    it "should not find tags and display appropriate message(with :maximum)" do
      expect { rendered.should have_tag('p', :max => 2) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at most 2 element(s) matching "p", found 3.}
      )
      expect { rendered.should have_tag('p', :maximum => 2) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto have at most 2 element(s) matching "p", found 3.}
      )
    end

    it "should find unexpected tags and display appropriate message(with :maximum)" do
      expect { rendered.should_not have_tag('p', :max => 5) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have at most 5 element(s) matching "p", but found 3.}
      )
      expect { rendered.should_not have_tag('p', :maximum => 5) }.to raise_spec_error(
        %Q{expected following:\n#{rendered}\nto NOT have at most 5 element(s) matching "p", but found 3.}
      )
    end

    it "should raise error when wrong params specified" do
      expect { rendered.should have_tag('div', :count => 'string') }.to raise_error(/wrong :count/)
      wrong_params_error_msg_1 = ':count with :minimum or :maximum has no sence!'
      expect { rendered.should have_tag('div', :count => 2, :minimum => 1) }.to raise_error(wrong_params_error_msg_1)
      expect { rendered.should have_tag('div', :count => 2, :min     => 1) }.to raise_error(wrong_params_error_msg_1)
      expect { rendered.should have_tag('div', :count => 2, :maximum => 1) }.to raise_error(wrong_params_error_msg_1)
      expect { rendered.should have_tag('div', :count => 2, :max     => 1) }.to raise_error(wrong_params_error_msg_1)
      wrong_params_error_msg_2 = ':minimum shold be less than :maximum!'
      expect { rendered.should have_tag('div', :minimum => 2, :maximum => 1) }.to raise_error(wrong_params_error_msg_2)
      [ 4..1, -2..6, 'a'..'z', 3..-9 ].each do |range|
        expect { rendered.should have_tag('div', :count => range ) }.to raise_error("Your :count range(#{range.to_s}) has no sence!")
      end
    end
  end

  context "with :text specified" do
    asset 'quotes'

    context 'using standard syntax' do

      it "should find tags" do
        rendered.should have_tag('div',  :text => 'sample text')
        rendered.should have_tag('p',    :text => 'one')
        rendered.should have_tag('div',  :text => /SAMPLE/i)
        rendered.should have_tag('span', :text => "sample with 'single' quotes")
        rendered.should have_tag('span', :text => %Q{sample with 'single' and "double" quotes})
        rendered.should have_tag('span', :text => /sample with 'single' and "double" quotes/)

        rendered.should have_tag('p',    :text => 'content with nbsp')
        rendered.should have_tag('pre',  :text => " 1. bla   \n 2. bla ")
      end

      it "should map a string argument to :text => string" do
        rendered.should have_tag('div',  'sample text')
      end

      it "should find with unicode text specified" do
        expect { rendered.should have_tag('a', :text => "học") }.to_not raise_exception(Encoding::CompatibilityError) if RUBY_VERSION =~ /^1\.9/
          rendered.should have_tag('a', :text => "học")
      end

      it "should not find tags" do
        rendered.should_not have_tag('p',      :text => 'text does not present')
        rendered.should_not have_tag('strong', :text => 'text does not present')
        rendered.should_not have_tag('p',      :text => /text does not present/)
        rendered.should_not have_tag('strong', :text => /text does not present/)

        rendered.should_not have_tag('p',      :text => 'contentwith nbsp')
        rendered.should_not have_tag('pre',    :text => "1. bla\n2. bla")
      end

      it "should invoke #to_s method for :text" do
        expect {
          rendered.should_not have_tag('p', :text => 100500 )
          rendered.should have_tag('p', :text => 315 )
        }.to_not raise_exception
      end

      it "should not find tags and display appropriate message" do
        # TODO make diffable,maybe...
        expect { rendered.should have_tag('div', :text => 'SAMPLE text') }.to raise_spec_error(
          %Q{"SAMPLE text" expected within "div" in following template:\n#{rendered}}
        )
        expect { rendered.should have_tag('div', :text => /SAMPLE tekzt/i) }.to raise_spec_error(
          %Q{/SAMPLE tekzt/i regexp expected within "div" in following template:\n#{rendered}}
        )
      end

      it "should find unexpected tags and display appropriate message" do
        expect { rendered.should_not have_tag('div', :text => 'sample text') }.to raise_spec_error(
          %Q{"sample text" unexpected within "div" in following template:\n#{rendered}\nbut was found.}
        )
        expect { rendered.should_not have_tag('div', :text => /SAMPLE text/i) }.to raise_spec_error(
          %Q{/SAMPLE text/i regexp unexpected within "div" in following template:\n#{rendered}\nbut was found.}
        )
      end

    end

    context 'using alternative syntax(with_text/without_text)' do

      it "should raise exception when used outside any other tag matcher" do
        expect { with_text 'sample text' }.to    raise_error(StandardError,/inside "have_tag"/)
        expect { without_text 'sample text' }.to raise_error(StandardError,/inside "have_tag"/)
      end

      it "should raise exception when used with block" do
        expect {
          rendered.should have_tag('div') do
            with_text 'sample text' do
              puts 'bla'
            end
          end
        }.to raise_error(ArgumentError,/does not accept block/)
        expect {
          rendered.should have_tag('div') do
            with_text 'sample text', proc { puts 'bla' }
          end
        }.to raise_error(ArgumentError)

        expect {
          rendered.should have_tag('div') do
            without_text 'sample text' do
              puts 'bla'
            end
          end
        }.to raise_error(ArgumentError,/does not accept block/)
        expect {
          rendered.should have_tag('div') do
            without_text 'sample text', proc { puts 'bla' }
          end
        }.to raise_error(ArgumentError)
      end

      it "should find tags" do
        rendered.should have_tag('div') do
          with_text 'sample text'
        end

        rendered.should have_tag('p') do
          with_text 'one'
        end

        rendered.should have_tag('div') do
          with_text /SAMPLE/i
        end

        rendered.should have_tag('span') do
          with_text "sample with 'single' quotes"
        end

        rendered.should have_tag('span') do
          with_text %Q{sample with 'single' and "double" quotes}
        end

        rendered.should have_tag('span') do
          with_text /sample with 'single' and "double" quotes/
        end


        rendered.should have_tag('p') do
          with_text 'content with nbsp'
        end

        rendered.should have_tag('pre') do
          with_text " 1. bla   \n 2. bla "
        end
      end

      it "should not find tags" do
        rendered.should have_tag('p') do
          but_without_text 'text does not present'
          without_text 'text does not present'
        end

        rendered.should have_tag('p') do
          but_without_text /text does not present/
          without_text /text does not present/
        end

        rendered.should have_tag('p') do
          but_without_text 'contentwith nbsp'
          without_text 'contentwith nbsp'
        end

        rendered.should have_tag('pre') do
          but_without_text "1. bla\n2. bla"
          without_text "1. bla\n2. bla"
        end
      end

      it "should not find tags and display appropriate message" do
        expect {
          rendered.should have_tag('div') do
            with_text 'SAMPLE text'
          end
        }.to raise_spec_error(
          %Q{"SAMPLE text" expected within "div" in following template:\n<div>sample text</div>}
        )
        expect {
          rendered.should have_tag('div') do
            with_text /SAMPLE tekzt/i
          end
        }.to raise_spec_error(
          %Q{/SAMPLE tekzt/i regexp expected within "div" in following template:\n<div>sample text</div>}
        )
      end

      it "should find unexpected tags and display appropriate message" do
        expect {
          rendered.should have_tag('div') do
            without_text 'sample text'
          end
        }.to raise_spec_error(
          %Q{"sample text" unexpected within "div" in following template:\n<div>sample text</div>\nbut was found.}
        )
        expect {
          rendered.should have_tag('div') do
            without_text /SAMPLE text/i
          end
        }.to raise_spec_error(
          %Q{/SAMPLE text/i regexp unexpected within "div" in following template:\n<div>sample text</div>\nbut was found.}
        )
      end

    end

  end

  context "mixed matching" do
    asset 'special'

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
    asset 'ordered_list'

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
      expect {
        rendered.should have_tag('ol') do
          with_tag('div')
        end
      }.to raise_spec_error(/have at least 1 element matching "div", found 0/)
    end

    it "should not find tags and display appropriate message" do
      ordered_list_regexp = rendered[/<ol.*<\/ol>/m].gsub(/(\n?\s{2,}|\n\s?)/,'\n*\s*')
      expect {
        rendered.should have_tag('ol') { with_tag('li'); with_tag('div') }
      }.to raise_spec_error(/expected following:\n#{ordered_list_regexp}\n\s*to have at least 1 element matching "div", found 0/)
      expect {
        rendered.should have_tag('ol') { with_tag('li'); with_tag('li', :count => 10) }
      }.to raise_spec_error(/expected following:\n#{ordered_list_regexp}\n\s*to have 10 element\(s\) matching "li", found 3/)
      expect {
        rendered.should have_tag('ol') { with_tag('li'); with_tag('li', :text => /SAMPLE text/i) }
      }.to raise_spec_error(/\/SAMPLE text\/i regexp expected within "li" in following template:\n#{ordered_list_regexp}/)
    end
  end
end
