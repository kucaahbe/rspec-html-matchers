require 'nokogiri'

module RSpec
  module Matchers

    # @api
    # @private
    class NokogiriMatcher#:nodoc:
      attr_reader :failure_message
      attr_reader :parent_scope, :current_scope

      def initialize tag, options={}, &block
        @tag, @options, @block = tag.to_s, options, block

	if attrs = @options.delete(:with)
	  if classes=attrs.delete(:class)
	    classes = case classes
		      when Array
			classes.join('.')
		      when String
			classes.gsub("\s",'.')
		      end
	    @tag << '.'+classes
	  end
	  html_attrs_string=''
	  attrs.each_pair { |k,v| html_attrs_string << %Q{[#{k.to_s}='#{v.to_s}']} }
	  @tag << html_attrs_string
	end

	# TODO add min and max processing
	@options[:minimum] ||= @options.delete(:min)
	@options[:maximum] ||= @options.delete(:max)
      end

      def matches? document, &block
	@block = block if block

	case document
	when String
	  @parent_scope = @current_scope = Nokogiri::HTML(document).css(@tag)
	  @document = document
	else
	  @parent_scope = document.current_scope
	  @current_scope = document.parent_scope.css(@tag)
	  @document = @parent_scope.to_html
	end

	if tag_presents? and count_right? and content_right?
	  @current_scope = @parent_scope
	  @block.call if @block
	  true
	else
	  false
	end
      end

      private

      def tag_presents?
	if @current_scope.first
	  @count = @current_scope.count
	  true
	else
	  @failure_message = %Q{expected following:\n#{@document}\nto have at least 1 element matching "#{@tag}", found 0.}
	  false
	end
      end

      def count_right?
	case @options[:count]
	when Integer
	  @count == @options[:count] || (@failure_message=%Q{expected following:\n#{@document}\nto have #{@options[:count]} element(s) matching "#{@tag}", found #{@count}.}; false)
	when Range
	  @options[:count].member?(@count) || (@failure_message=%Q{expected following:\n#{@document}\nto have at least #{@options[:count].min} and at most #{@options[:count].max} element(s) matching "#{@tag}", found #{@count}.}; false)
	when nil
	  if @options[:maximum]
	    @count <= @options[:maximum] || (@failure_message=%Q{expected following:\n#{@document}\nto have at most #{@options[:maximum]} element(s) matching "#{@tag}", found #{@count}.}; false)
	  elsif @options[:minimum]
	    @count >= @options[:minimum] || (@failure_message=%Q{expected following:\n#{@document}\nto have at least #{@options[:minimum]} element(s) matching "#{@tag}", found #{@count}.}; false)
	  else
	    true
	  end
	else
	  @failure_message = 'wrong count specified'
	  return false
	end
      end

      def content_right?
	return true unless @options[:text]

	case text=@options[:text]
	when Regexp
	  if @current_scope.any? {|node| node.content =~ text }
	    true
	  else
	    @failure_message=%Q{#{text.inspect} regexp expected within "#{@tag}" in following template:\n#{@document}}
	    false
	  end
	else
	  if @current_scope.any? {|node| node.content == text }
	    true
	  else
	    @failure_message=%Q{"#{text}" expected within "#{@tag}" in following template:\n#{@document}}
	    false
	  end
	end
      end
    end

    # have_tag matcher
    #
    # @yield block where you should put with_tag
    #
    # @param [String] tag     css selector for tag you want to match
    # @param [Hash]   options options hash(see below)
    # @option options [Hash]   :with  hash with other attributes, within this, key :class have special meaning, you may specify it as array of expected classes or string of classes separated by spaces, order does not matter
    # @option options [Fixnum] :count count of matched tags(DO NOT USE :count with :minimum(:min) or :maximum(:max)*)
    # @option options [Range]  :count count of matched tags should be between range minimum and maximum values
    # @option options [Fixnum] :minimum minimum count of elements to match
    # @option options [Fixnum] :min same as :minimum
    # @option options [Fixnum] :maximum maximum count of elements to match
    # @option options [Fixnum] :max same as :maximum
    #
    #
    # @example
    #   rendered.should have_tag('div')
    #   rendered.should have_tag('h1.header')
    #   rendered.should have_tag('div#footer')
    #   rendered.should have_tag('input#email', :with => { :name => 'user[email]', :type => 'email' } )
    #   rendered.should have_tag('div', :count => 3)            # matches exactly 3 'div' tags
    #   rendered.should have_tag('div', :count => 3..7)         # something like have_tag('div', :minimum => 3, :maximum => 7)
    #   rendered.should have_tag('div', :minimum => 3)          # matches more(or equal) than 3 'div' tags
    #   rendered.should have_tag('div', :maximum => 3)          # matches less(or equal) than 3 'div' tags
    #   rendered.should have_tag('p', :text => 'some content')  # will match "<p>some content</p>"
    #   rendered.should have_tag('p', :text => /some content/i) # will match "<p>sOme cOntEnt</p>"
    #   "<html>
    #     <body>
    #       <h1>some html document</h1>
    #     </body>
    #    </html>".should have_tag('body') { with_tag('h1', :text => 'some html document') }
    #   '<div class="one two">'.should have_tag('div', :with => { :class => ['two', 'one'] })
    #   '<div class="one two">'.should have_tag('div', :with => { :class => 'two one' })
    def have_tag tag, options={}, &block
      @__current_scope_for_nokogiri_matcher = NokogiriMatcher.new(tag, options, &block)
    end

    # with_tag matcher
    # @yield
    # @see #have_tag
    # @note this should be used within block of have_tag matcher
    def with_tag tag, options={}, &block
      @__current_scope_for_nokogiri_matcher.should have_tag(tag, options, &block)
    end

    # without_tag matcher
    # @yield
    # @see #have_tag
    # @note this should be used within block of have_tag matcher
    def without_tag tag, options={}, &block
      @__current_scope_for_nokogiri_matcher.should_not have_tag(tag, options, &block)
    end

    def have_form action_url, method, options={}, &block
      options[:with] ||= {}
      id = options[:with].delete(:id)
      tag = 'form'; tag += '#'+id if id
      options[:with].merge!(:action => action_url)
      options[:with].merge!(:method => method.to_s)
      have_tag tag, options, &block
    end

    def with_select name, options={}, &block
      options[:with] ||= {}
      id = options[:with].delete(:id)
      tag='select'; tag += '#'+id if id
      options[:with].merge!(:name => name)
      @__current_scope_for_nokogiri_matcher.should have_tag(tag, options, &block)
    end

    def without_select name, options={}, &block
      options[:with] ||= {}
      id = options[:with].delete(:id)
      tag='select'; tag += '#'+id if id
      options[:with].merge!(:name => name)
      @__current_scope_for_nokogiri_matcher.should_not have_tag(tag, options, &block)
    end

    def with_option text, value=nil, options={}
      options[:with] ||= {}
      if value.is_a?(Hash)
	options.merge!(value)
	value=nil
      end
      tag='option'
      options[:with].merge!(:value => value.to_s) if value
      if options[:selected]
	options[:with].merge!(:selected => "selected")
      end
      options.delete(:selected)
      options.merge!(:text => text) if text
      @__current_scope_for_nokogiri_matcher.should have_tag(tag, options)
    end

    def without_option text, value=nil, options={}
      options[:with] ||= {}
      if value.is_a?(Hash)
	options.merge!(value)
	value=nil
      end
      tag='option'
      options[:with].merge!(:value => value.to_s) if value
      if options[:selected]
	options[:with].merge!(:selected => "selected")
      end
      options.delete(:selected)
      options.merge!(:text => text) if text
      @__current_scope_for_nokogiri_matcher.should_not have_tag(tag, options)
    end

  end
end
