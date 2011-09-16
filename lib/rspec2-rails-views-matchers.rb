require 'nokogiri'

module RSpec
  module Matchers

    # @api
    # @private
    class NokogiriMatcher
      attr_reader :failure_message, :negative_failure_message
      attr_reader :parent_scope, :current_scope

      TAG_NOT_FOUND_MSG    = %Q|expected following:\n%s\nto have at least 1 element matching "%s", found 0.|
      TAG_FOUND_MSG        = %Q|expected following:\n%s\nto NOT have element matching "%s", found %s.|
      WRONG_COUNT_MSG      = %Q|expected following:\n%s\nto have %s element(s) matching "%s", found %s.|
      RIGHT_COUNT_MSG      = %Q|expected following:\n%s\nto NOT have %s element(s) matching "%s", but found.|
      BETWEEN_COUNT_MSG    = %Q|expected following:\n%s\nto have at least %s and at most %s element(s) matching "%s", found %s.|
      RIGHT_BETWEEN_COUNT_MSG = %Q|expected following:\n%s\nto NOT have at least %s and at most %s element(s) matching "%s", but found %s.|
      AT_MOST_MSG          = %Q|expected following:\n%s\nto have at most %s element(s) matching "%s", found %s.|
      RIGHT_AT_MOST_MSG    = %Q|expected following:\n%s\nto NOT have at most %s element(s) matching "%s", but found %s.|
      AT_LEAST_MSG         = %Q|expected following:\n%s\nto have at least %s element(s) matching "%s", found %s.|
      RIGHT_AT_LEAST_MSG   = %Q|expected following:\n%s\nto NOT have at least %s element(s) matching "%s", but found %s.|
      REGEXP_NOT_FOUND_MSG = %Q|%s regexp expected within "%s" in following template:\n%s|
      REGEXP_FOUND_MSG     = %Q|%s regexp unexpected within "%s" in following template:\n%s\nbut was found.|
      TEXT_NOT_FOUND_MSG   = %Q|"%s" expected within "%s" in following template:\n%s|
      TEXT_FOUND_MSG       = %Q|"%s" unexpected within "%s" in following template:\n%s\nbut was found.|
      WRONG_COUNT_ERROR_MSG= %Q|:count with :minimum or :maximum has no sence!|
      MIN_MAX_ERROR_MSG    = %Q|:minimum shold be less than :maximum!|
      BAD_RANGE_ERROR_MSG  = %Q|Your :count range(%s) has no sence!|

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

        [:min, :minimum, :max, :maximum].each do |key|
          raise WRONG_COUNT_ERROR_MSG if @options.has_key?(key) and @options.has_key?(:count)
        end

        begin
          raise MIN_MAX_ERROR_MSG if @options[:minimum] > @options[:maximum]
        rescue NoMethodError # nil > 4
        rescue ArgumentError # 2 < nil
        end

        begin
          raise BAD_RANGE_ERROR_MSG % [@options[:count].to_s] if @options[:count] && @options[:count].is_a?(Range) && (@options[:count].min.nil? or @options[:count].min < 0)
        rescue ArgumentError, /comparison of String with/ # if @options[:count] == 'a'..'z'
          raise BAD_RANGE_ERROR_MSG % [@options[:count].to_s]
        end

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

	if tag_presents? and content_right? and count_right?
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
          @negative_failure_message = TAG_FOUND_MSG % [@document, @tag, @count]
	  true
	else
	  @failure_message = TAG_NOT_FOUND_MSG % [@document, @tag]
	  false
	end
      end

      def count_right?
	case @options[:count]
	when Integer
	  ((@negative_failure_message=RIGHT_COUNT_MSG % [@document,@count,@tag]) && @count == @options[:count]) || (@failure_message=WRONG_COUNT_MSG % [@document,@options[:count],@tag,@count]; false)
	when Range
	  ((@negative_failure_message=RIGHT_BETWEEN_COUNT_MSG % [@document,@options[:count].min,@options[:count].max,@tag,@count]) && @options[:count].member?(@count)) || (@failure_message=BETWEEN_COUNT_MSG % [@document,@options[:count].min,@options[:count].max,@tag,@count]; false)
	when nil
	  if @options[:maximum]
	    ((@negative_failure_message=RIGHT_AT_MOST_MSG % [@document,@options[:maximum],@tag,@count]) && @count <= @options[:maximum]) || (@failure_message=AT_MOST_MSG % [@document,@options[:maximum],@tag,@count]; false)
	  elsif @options[:minimum]
	    ((@negative_failure_message=RIGHT_AT_LEAST_MSG % [@document,@options[:minimum],@tag,@count]) && @count >= @options[:minimum]) || (@failure_message=AT_LEAST_MSG % [@document,@options[:minimum],@tag,@count]; false)
	  else
	    true
	  end
	else
	  @failure_message = 'wrong count specified'
	  false
	end
      end

      def content_right?
	return true unless @options[:text]

	case text=@options[:text]
	when Regexp
	  new_scope = @current_scope.css(":regexp('#{text}')",Class.new {
	    def regexp node_set, text
	      node_set.find_all { |node| node.content =~ Regexp.new(text) }
	    end
	  }.new)
	  unless new_scope.empty?
	    @count = new_scope.count
            @negative_failure_message = REGEXP_FOUND_MSG % [text.inspect,@tag,@document]
	    true
	  else
	    @failure_message=REGEXP_NOT_FOUND_MSG % [text.inspect,@tag,@document]
	    false
	  end
	else
    css_param = text.gsub(/'/) { %q{\000027} }
    new_scope = @current_scope.css(":content('#{css_param}')",Class.new {
	    def content node_set, text
        match_text = text.gsub(/\\000027/, "'")
	      node_set.find_all { |node| node.content == match_text }
	    end
	  }.new)
	  unless new_scope.empty?
	    @count = new_scope.count
            @negative_failure_message = TEXT_FOUND_MSG % [text,@tag,@document]
	    true
	  else
	    @failure_message=TEXT_NOT_FOUND_MSG % [text,@tag,@document]
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
    #   rendered.should have_tag('textarea', :with => {:name => 'user[description]'}, :text => "I like pie")
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

    def with_hidden_field name, value=nil
      options = { :with => { :name => name, :type => 'hidden' } }
      options[:with].merge!(:value => value) if value
      should_have_input(options)
    end

    def without_hidden_field name, value=nil
      options = { :with => { :name => name, :type => 'hidden' } }
      options[:with].merge!(:value => value) if value
      should_not_have_input(options)
    end

    def with_text_field name, value=nil
      options = { :with => { :name => name, :type => 'text' } }
      options[:with].merge!(:value => value) if value
      should_have_input(options)
    end

    def without_text_field name, value=nil
      options = { :with => { :name => name, :type => 'text' } }
      options[:with].merge!(:value => value) if value
      should_not_have_input(options)
    end

    def with_email_field name, value=nil
      options = { :with => { :name => name, :type => 'email' } }
      options[:with].merge!(:value => value) if value
      should_have_input(options)
    end

    def without_email_field name, value=nil
      options = { :with => { :name => name, :type => 'email' } }
      options[:with].merge!(:value => value) if value
      should_not_have_input(options)
    end

    def with_password_field name
      options = { :with => { :name => name, :type => 'password' } }
      should_have_input(options)
    end

    def without_password_field name
      options = { :with => { :name => name, :type => 'password' } }
      should_not_have_input(options)
    end

    def with_file_field name
      options = { :with => { :name => name, :type => 'file' } }
      should_have_input(options)
    end

    def without_file_field name
      options = { :with => { :name => name, :type => 'file' } }
      should_not_have_input(options)
    end

    def with_text_area name
      options = { :with => { :name => name } }
      @__current_scope_for_nokogiri_matcher.should have_tag('textarea', options)
    end

    def without_text_area name
      options = { :with => { :name => name } }
      @__current_scope_for_nokogiri_matcher.should_not have_tag('textarea', options)
    end

    def with_checkbox name, value=nil
      options = { :with => { :name => name, :type => 'checkbox' } }
      options[:with].merge!(:value => value) if value
      should_have_input(options)
    end

    def without_checkbox name, value=nil
      options = { :with => { :name => name, :type => 'checkbox' } }
      options[:with].merge!(:value => value) if value
      should_not_have_input(options)
    end

    def with_radio_button name, value
      options = { :with => { :name => name, :type => 'radio' } }
      options[:with].merge!(:value => value)
      should_have_input(options)
    end

    def without_radio_button name, value
      options = { :with => { :name => name, :type => 'radio' } }
      options[:with].merge!(:value => value)
      should_not_have_input(options)
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

    def with_submit value
      options = { :with => { :type => 'submit', :value => value } }
      should_have_input(options)
    end

    def without_submit value
      options = { :with => { :type => 'submit', :value => value } }
      should_not_have_input(options)
    end

    private

    def should_have_input(options)
      @__current_scope_for_nokogiri_matcher.should have_tag('input', options)
    end

    def should_not_have_input(options)
      @__current_scope_for_nokogiri_matcher.should_not have_tag('input', options)
    end

  end
end
