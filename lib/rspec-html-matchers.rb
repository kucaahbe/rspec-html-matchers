# encoding: UTF-8
require 'nokogiri'

module RSpec
  module Matchers

    # @api
    # @private
    # for nokogiri regexp matching
    class NokogiriRegexpHelper
      def initialize(regex)
        @regex = regex
      end

      def regexp node_set
        node_set.find_all { |node| node.content =~ @regex }
      end
    end

    # @api
    # @private
    class NokogiriTextHelper
      def initialize text
        @text = text
      end

      def content node_set
        match_text = @text.gsub(/\\000027/, "'")
        node_set.find_all do |node|
          actual_content = node.content
          # remove non-breaking spaces:
          case RUBY_VERSION
          # 1.9.x 2.x.x rubies
          when /^(1\.9|2)/
            actual_content.gsub!(/\u00a0/, ' ')
          when /^1\.8/
            actual_content.gsub!("\302\240", ' ')
          end

          actual_content == match_text
        end
      end
    end

    # @api
    # @private
    class NokogiriMatcher
      attr_reader :failure_message, :negative_failure_message
      attr_reader :parent_scope, :current_scope

      TAG_FOUND_DESC           = %Q|have at least 1 element matching "%s"|
      TAG_NOT_FOUND_MSG        = %Q|expected following:\n%s\nto #{TAG_FOUND_DESC}, found 0.|
      TAG_FOUND_MSG            = %Q|expected following:\n%s\nto NOT have element matching "%s", found %s.|
      COUNT_DESC               = %Q|have %s element(s) matching "%s"|
      WRONG_COUNT_MSG          = %Q|expected following:\n%s\nto #{COUNT_DESC}, found %s.|
      RIGHT_COUNT_MSG          = %Q|expected following:\n%s\nto NOT have %s element(s) matching "%s", but found.|
      BETWEEN_COUNT_MSG        = %Q|expected following:\n%s\nto have at least %s and at most %s element(s) matching "%s", found %s.|
      RIGHT_BETWEEN_COUNT_MSG  = %Q|expected following:\n%s\nto NOT have at least %s and at most %s element(s) matching "%s", but found %s.|
      AT_MOST_MSG              = %Q|expected following:\n%s\nto have at most %s element(s) matching "%s", found %s.|
      RIGHT_AT_MOST_MSG        = %Q|expected following:\n%s\nto NOT have at most %s element(s) matching "%s", but found %s.|
      AT_LEAST_MSG             = %Q|expected following:\n%s\nto have at least %s element(s) matching "%s", found %s.|
      RIGHT_AT_LEAST_MSG       = %Q|expected following:\n%s\nto NOT have at least %s element(s) matching "%s", but found %s.|
      REGEXP_NOT_FOUND_MSG     = %Q|%s regexp expected within "%s" in following template:\n%s|
      REGEXP_FOUND_MSG         = %Q|%s regexp unexpected within "%s" in following template:\n%s\nbut was found.|
      TEXT_NOT_FOUND_MSG       = %Q|"%s" expected within "%s" in following template:\n%s|
      TEXT_FOUND_MSG           = %Q|"%s" unexpected within "%s" in following template:\n%s\nbut was found.|
      WRONG_COUNT_ERROR_MSG    = %Q|:count with :minimum or :maximum has no sence!|
      MIN_MAX_ERROR_MSG        = %Q|:minimum shold be less than :maximum!|
      BAD_RANGE_ERROR_MSG      = %Q|Your :count range(%s) has no sence!|

      def initialize tag, options={}, &block
        @tag, @options, @block = tag.to_s, options, block

        if with_attrs = @options.delete(:with)
          if classes = with_attrs.delete(:class)
            @tag << '.' + classes_to_selector(classes)
          end
          selector = with_attrs.inject('') do |html_attrs_string, (k, v)|
            html_attrs_string << "[#{k}='#{v}']"
            html_attrs_string
          end
          @tag << selector
        end

        if without_attrs = @options.delete(:without)
          if classes = without_attrs.delete(:class)
            @tag << ":not(.#{classes_to_selector(classes)})"
          end
        end

        validate_options!
      end

      def matches? document, &block
        @block = block if block

        document = document.html if defined?(Capybara::Session) && document.is_a?(Capybara::Session)

        case document
        when String
          @parent_scope = @current_scope = Nokogiri::HTML(document).css(@tag)
          @document     = document
        else
          @parent_scope  = document.current_scope
          @current_scope = document.parent_scope.css(@tag)
          @document      = @parent_scope.to_html
        end

        if tag_presents? and text_right? and count_right?
          @current_scope = @parent_scope
          @block.call if @block
          true
        else
          false
        end
      end

      def description
        # TODO should it be more complicated?
        if @options.has_key?(:count)
          COUNT_DESC % [@options[:count],@tag]
        else
          TAG_FOUND_DESC % @tag
        end
      end

      private

      def classes_to_selector(classes)
        case classes
        when Array
          classes.join('.')
        when String
          classes.gsub(/\s+/, '.')
        end
      end

      def tag_presents?
        if @current_scope.first
          @count = @current_scope.count
          @negative_failure_message = TAG_FOUND_MSG % [@document, @tag, @count]
          true
        else
          @failure_message          = TAG_NOT_FOUND_MSG % [@document, @tag]
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
        end
      end

      def text_right?
        return true unless @options[:text]

        case text=@options[:text]
        when Regexp
          new_scope = @current_scope.css(':regexp()',NokogiriRegexpHelper.new(text))
          unless new_scope.empty?
            @count = new_scope.count
            @negative_failure_message = REGEXP_FOUND_MSG % [text.inspect,@tag,@document]
            true
          else
            @failure_message          = REGEXP_NOT_FOUND_MSG % [text.inspect,@tag,@document]
            false
          end
        else
          new_scope = @current_scope.css(':content()',NokogiriTextHelper.new(text))
          unless new_scope.empty?
            @count = new_scope.count
            @negative_failure_message = TEXT_FOUND_MSG % [text,@tag,@document]
            true
          else
            @failure_message          = TEXT_NOT_FOUND_MSG % [text,@tag,@document]
            false
          end
        end
      end

      protected

      def validate_options!
        raise 'wrong :count specified' unless [Range, NilClass].include?(@options[:count].class) or @options[:count].is_a?(Integer)

        [:min, :minimum, :max, :maximum].each do |key|
          raise WRONG_COUNT_ERROR_MSG if @options.has_key?(key) and @options.has_key?(:count)
        end

        begin
          raise MIN_MAX_ERROR_MSG if @options[:minimum] > @options[:maximum]
        rescue NoMethodError # nil > 4
        rescue ArgumentError # 2 < nil
        end

        begin
          begin
            raise BAD_RANGE_ERROR_MSG % [@options[:count].to_s] if @options[:count] && @options[:count].is_a?(Range) && (@options[:count].min.nil? or @options[:count].min < 0)
          rescue ArgumentError, "comparison of String with" # if @options[:count] == 'a'..'z'
            raise BAD_RANGE_ERROR_MSG % [@options[:count].to_s]
          end
        rescue TypeError # fix for 1.8.7 for 'rescue ArgumentError, "comparison of String with"' stroke
          raise BAD_RANGE_ERROR_MSG % [@options[:count].to_s]
        end

        @options[:minimum] ||= @options.delete(:min)
        @options[:maximum] ||= @options.delete(:max)

        @options[:text] = @options[:text].to_s if @options.has_key?(:text) && !@options[:text].is_a?(Regexp)
      end

    end

    # tag assertion, this is the core of functionality, other matchers are shortcuts to this matcher
    #
    # @yield block where you should put with_tag, without_tag and/or other matchers
    #
    # @param [String] tag     css selector for tag you want to match, e.g. 'div', 'section#my', 'article.red'
    # @param [Hash]   options options hash(see below)
    # @option options [Hash]   :with  hash with html attributes, within this, *:class* option have special meaning, you may specify it as array of expected classes or string of classes separated by spaces, order does not matter
    # @option options [Fixnum] :count for tag count matching(*ATTENTION:* do not use :count with :minimum(:min) or :maximum(:max))
    # @option options [Range]  :count not strict tag count matching, count of tags should be in specified range
    # @option options [Fixnum] :minimum minimum count of elements to match
    # @option options [Fixnum] :min same as :minimum
    # @option options [Fixnum] :maximum maximum count of elements to match
    # @option options [Fixnum] :max same as :maximum
    # @option options [String/Regexp] :text to match tag content, could be either String or Regexp
    #
    # @example
    #   rendered.should have_tag('div')
    #   rendered.should have_tag('h1.header')
    #   rendered.should have_tag('div#footer')
    #   rendered.should have_tag('input#email', :with => { :name => 'user[email]', :type => 'email' } )
    #   rendered.should have_tag('div', :count => 3)            # matches exactly 3 'div' tags
    #   rendered.should have_tag('div', :count => 3..7)         # shortcut for have_tag('div', :minimum => 3, :maximum => 7)
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
      # for backwards compatibility with rpecs have tag:
      options = { :text => options } if options.kind_of? String
      @__current_scope_for_nokogiri_matcher = NokogiriMatcher.new(tag, options, &block)
    end

    def with_text text
      raise StandardError, 'this matcher should be used inside "have_tag" matcher block' unless defined?(@__current_scope_for_nokogiri_matcher)
      raise ArgumentError, 'this matcher does not accept block' if block_given?
      tag = @__current_scope_for_nokogiri_matcher.instance_variable_get(:@tag)
      @__current_scope_for_nokogiri_matcher.should have_tag(tag, :text => text)
    end

    def without_text text
      raise StandardError, 'this matcher should be used inside "have_tag" matcher block' unless defined?(@__current_scope_for_nokogiri_matcher)
      raise ArgumentError, 'this matcher does not accept block' if block_given?
      tag = @__current_scope_for_nokogiri_matcher.instance_variable_get(:@tag)
      @__current_scope_for_nokogiri_matcher.should_not have_tag(tag, :text => text)
    end
    alias :but_without_text :without_text

    # with_tag matcher
    # @yield block where you should put other with_tag or without_tag
    # @see #have_tag
    # @note this should be used within block of have_tag matcher
    def with_tag tag, options={}, &block
      @__current_scope_for_nokogiri_matcher.should have_tag(tag, options, &block)
    end

    # without_tag matcher
    # @yield block where you should put other with_tag or without_tag
    # @see #have_tag
    # @note this should be used within block of have_tag matcher
    def without_tag tag, options={}, &block
      @__current_scope_for_nokogiri_matcher.should_not have_tag(tag, options, &block)
    end

    # form assertion
    #
    # it is a shortcut to
    #   have_tag 'form', :with => { :action => action_url, :method => method ... }
    # @yield block with with_<field>, see below
    # @see #have_tag
    def have_form action_url, method, options={}, &block
      options[:with] ||= {}
      id = options[:with].delete(:id)
      tag = 'form'; tag << '#'+id if id
      options[:with].merge!(:action => action_url)
      options[:with].merge!(:method => method.to_s)
      have_tag tag, options, &block
    end

    #TODO fix code duplications

    def with_hidden_field name, value=nil
      options = form_tag_options('hidden',name,value)
      should_have_input(options)
    end

    def without_hidden_field name, value=nil
      options = form_tag_options('hidden',name,value)
      should_not_have_input(options)
    end

    def with_text_field name, value=nil
      options = form_tag_options('text',name,value)
      should_have_input(options)
    end

    def without_text_field name, value=nil
      options = form_tag_options('text',name,value)
      should_not_have_input(options)
    end

    def with_email_field name, value=nil
      options = form_tag_options('email',name,value)
      should_have_input(options)
    end

    def without_email_field name, value=nil
      options = form_tag_options('email',name,value)
      should_not_have_input(options)
    end

    def with_url_field name, value=nil
      options = form_tag_options('url',name,value)
      should_have_input(options)
    end

    def without_url_field name, value=nil
      options = form_tag_options('url',name,value)
      should_not_have_input(options)
    end

    def with_number_field name, value=nil
      options = form_tag_options('number',name,value)
      should_have_input(options)
    end

    def without_number_field name, value=nil
      options = form_tag_options('number',name,value)
      should_not_have_input(options)
    end

    def with_range_field name, min, max, options={}
      options = { :with => { :name => name, :type => 'range', :min => min.to_s, :max => max.to_s }.merge(options.delete(:with)||{}) }
      should_have_input(options)
    end

    def without_range_field name, min=nil, max=nil, options={}
      options = { :with => { :name => name, :type => 'range' }.merge(options.delete(:with)||{}) }
      options[:with].merge!(:min => min.to_s) if min
      options[:with].merge!(:max => max.to_s) if max
      should_not_have_input(options)
    end

    DATE_FIELD_TYPES = %w( date month week time datetime datetime-local )

    def with_date_field date_field_type, name=nil, options={}
      date_field_type = date_field_type.to_s
      raise "unknown type `#{date_field_type}` for date picker" unless DATE_FIELD_TYPES.include?(date_field_type)
      options = { :with => { :type => date_field_type.to_s }.merge(options.delete(:with)||{}) }
      options[:with].merge!(:name => name.to_s) if name
      should_have_input(options)
    end

    def without_date_field date_field_type, name=nil, options={}
      date_field_type = date_field_type.to_s
      raise "unknown type `#{date_field_type}` for date picker" unless DATE_FIELD_TYPES.include?(date_field_type)
      options = { :with => { :type => date_field_type.to_s }.merge(options.delete(:with)||{}) }
      options[:with].merge!(:name => name.to_s) if name
      should_not_have_input(options)
    end

    # TODO add ability to explicitly say that value should be empty
    def with_password_field name, value=nil
      options = form_tag_options('password',name,value)
      should_have_input(options)
    end

    def without_password_field name, value=nil
      options = form_tag_options('password',name,value)
      should_not_have_input(options)
    end

    def with_file_field name, value=nil
      options = form_tag_options('file',name,value)
      should_have_input(options)
    end

    def without_file_field name, value=nil
      options = form_tag_options('file',name,value)
      should_not_have_input(options)
    end

    def with_text_area name#TODO, text=nil
      #options = form_tag_options('text',name,value)
      options = { :with => { :name => name } }
      @__current_scope_for_nokogiri_matcher.should have_tag('textarea', options)
    end

    def without_text_area name#TODO, text=nil
      #options = form_tag_options('text',name,value)
      options = { :with => { :name => name } }
      @__current_scope_for_nokogiri_matcher.should_not have_tag('textarea', options)
    end

    def with_checkbox name, value=nil
      options = form_tag_options('checkbox',name,value)
      should_have_input(options)
    end

    def without_checkbox name, value=nil
      options = form_tag_options('checkbox',name,value)
      should_not_have_input(options)
    end

    def with_radio_button name, value
      options = form_tag_options('radio',name,value)
      should_have_input(options)
    end

    def without_radio_button name, value
      options = form_tag_options('radio',name,value)
      should_not_have_input(options)
    end

    def with_select name, options={}, &block
      options[:with] ||= {}
      id = options[:with].delete(:id)
      tag='select'; tag << '#'+id if id
      options[:with].merge!(:name => name)
      @__current_scope_for_nokogiri_matcher.should have_tag(tag, options, &block)
    end

    def without_select name, options={}, &block
      options[:with] ||= {}
      id = options[:with].delete(:id)
      tag='select'; tag << '#'+id if id
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

    def with_button text, value=nil, options={}
      options[:with] ||= {}
      if value.is_a?(Hash)
        options.merge!(value)
        value=nil
      end
      options[:with].merge!(:value => value.to_s) if value
      options.merge!(:text => text) if text
      @__current_scope_for_nokogiri_matcher.should have_tag('button', options)
    end

    def without_button text, value=nil, options={}
      options[:with] ||= {}
      if value.is_a?(Hash)
        options.merge!(value)
        value=nil
      end
      options[:with].merge!(:value => value.to_s) if value
      options.merge!(:text => text) if text
      @__current_scope_for_nokogiri_matcher.should_not have_tag('button', options)
    end

    def with_submit value
      options = { :with => { :type => 'submit', :value => value } }
      #options = form_tag_options('text',name,value)
      should_have_input(options)
    end

    def without_submit value
      #options = form_tag_options('text',name,value)
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

    # form_tag in method name name mean smth. like input, submit, tags that should appear in a form
    def form_tag_options form_tag_type, form_tag_name, form_tag_value=nil
      options = { :with => { :name => form_tag_name, :type => form_tag_type } }
      # .to_s if value is a digit or smth. else, see issue#10
      options[:with].merge!(:value => form_tag_value.to_s) if form_tag_value
      return options
    end

  end
end
