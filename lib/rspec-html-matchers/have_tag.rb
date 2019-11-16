# encoding: UTF-8
# frozen_string_literal: true

require 'nokogiri'

module RSpecHtmlMatchers
  # @api
  # @private
  class HaveTag
    attr_reader :failure_message, :failure_message_when_negated
    attr_reader :parent_scope, :current_scope

    DESCRIPTIONS = {
      :have_at_least_1 => %(have at least 1 element matching "%s"),
      :have_n          => %|have %i element(s) matching "%s"|,
    }.freeze

    MESSAGES = {
      :expected_tag         => %(expected following:\n%s\nto #{DESCRIPTIONS[:have_at_least_1]}, found 0.),
      :unexpected_tag       => %(expected following:\n%s\nto NOT have element matching "%s", found %s.),

      :expected_count       => %(expected following:\n%s\nto #{DESCRIPTIONS[:have_n]}, found %s.),
      :unexpected_count     => %|expected following:\n%s\nto NOT have %i element(s) matching "%s", but found.|,

      :expected_btw_count   => %|expected following:\n%s\nto have at least %i and at most %i element(s) matching "%s", found %i.|,
      :unexpected_btw_count => %|expected following:\n%s\nto NOT have at least %i and at most %i element(s) matching "%s", but found %i.|,

      :expected_at_most     => %|expected following:\n%s\nto have at most %i element(s) matching "%s", found %i.|,
      :unexpected_at_most   => %|expected following:\n%s\nto NOT have at most %i element(s) matching "%s", but found %i.|,

      :expected_at_least    => %|expected following:\n%s\nto have at least %i element(s) matching "%s", found %i.|,
      :unexpected_at_least  => %|expected following:\n%s\nto NOT have at least %i element(s) matching "%s", but found %i.|,

      :expected_blank       => %(expected following template to contain empty tag %s:\n%s),
      :unexpected_blank     => %(expected following template to contain tag %s with other tags:\n%s),

      :expected_regexp      => %(%s regexp expected within "%s" in following template:\n%s),
      :unexpected_regexp    => %(%s regexp unexpected within "%s" in following template:\n%s\nbut was found.),

      :expected_text        => %("%s" expected within "%s" in following template:\n%s),
      :unexpected_text      => %("%s" unexpected within "%s" in following template:\n%s\nbut was found.),

      :wrong_count_error    => %(:count with :minimum or :maximum has no sence!),
      :min_max_error        => %(:minimum should be less than :maximum!),
      :bad_range_error      => %|Your :count range(%s) has no sence!|,
    }.freeze

    def initialize tag, options = {}, &block
      @tag = tag.to_s
      @options = options
      @block = block

      if with_attrs = @options.delete(:with)
        if classes = with_attrs.delete(:class)
          @tag += '.' + classes_to_selector(classes)
        end
        selector = with_attrs.inject('') do |html_attrs_string, (k, v)|
          html_attrs_string += "[#{k}='#{v}']"
          html_attrs_string
        end
        @tag += selector
      end

      if without_attrs = @options.delete(:without)
        if classes = without_attrs.delete(:class)
          @tag += ":not(.#{classes_to_selector(classes)})"
        end
      end

      validate_options!
      set_options
    end

    def matches? document, &block
      @block = block if block

      document = document.html if defined?(Capybara::Session) && document.is_a?(Capybara::Session)

      case document
      when String
        @parent_scope = Nokogiri::HTML(document)
        @document     = document
      else
        @parent_scope  = document.current_scope
        @document      = @parent_scope.to_html
      end
      @current_scope = begin
                         @parent_scope.css(@tag)
                         # on jruby this produce exception if css was not found:
                         # undefined method `decorate' for nil:NilClass
                       rescue NoMethodError
                         Nokogiri::XML::NodeSet.new(Nokogiri::XML::Document.new)
                       end
      if tag_presents? && proper_content? && count_right?
        @block.call(self) if @block
        true
      else
        false
      end
    end

    attr_reader :document

    def description
      # TODO: should it be more complicated?
      if @options.key?(:count)
        format(DESCRIPTIONS[:have_n], @options[:count], @tag)
      else
        DESCRIPTIONS[:have_at_least_1] % @tag
      end
    end

    private

    def classes_to_selector classes
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
        @failure_message_when_negated = format(MESSAGES[:unexpected_tag], @document, @tag, @count)
        true
      else
        @failure_message = format(MESSAGES[:expected_tag], @document, @tag)
        false
      end
    end

    def count_right?
      case @options[:count]
      when Integer
        ((@failure_message_when_negated = format(MESSAGES[:unexpected_count], @document, @count, @tag)) && @count == @options[:count]) || (@failure_message = format(MESSAGES[:expected_count], @document, @options[:count], @tag, @count); false)
      when Range
        ((@failure_message_when_negated = format(MESSAGES[:unexpected_btw_count], @document, @options[:count].min, @options[:count].max, @tag, @count)) && @options[:count].member?(@count)) || (@failure_message = format(MESSAGES[:expected_btw_count], @document, @options[:count].min, @options[:count].max, @tag, @count); false)
      when nil
        if @options[:maximum]
          ((@failure_message_when_negated = format(MESSAGES[:unexpected_at_most], @document, @options[:maximum], @tag, @count)) && @count <= @options[:maximum]) || (@failure_message = format(MESSAGES[:expected_at_most], @document, @options[:maximum], @tag, @count); false)
        elsif @options[:minimum]
          ((@failure_message_when_negated = format(MESSAGES[:unexpected_at_least], @document, @options[:minimum], @tag, @count)) && @count >= @options[:minimum]) || (@failure_message = format(MESSAGES[:expected_at_least], @document, @options[:minimum], @tag, @count); false)
        else
          true
        end
      end
    end

    def proper_content?
      if @options.key?(:blank)
        maybe_empty?
      else
        text_right?
      end
    end

    def maybe_empty?
      if @options[:blank]
        @failure_message_when_negated = format(MESSAGES[:unexpected_blank], @tag, @document)
        @failure_message = format(MESSAGES[:expected_blank], @tag, @document)
      else
        @failure_message_when_negated = format(MESSAGES[:expected_blank], @tag, @document)
        @failure_message = format(MESSAGES[:unexpected_blank], @tag, @document)
      end

      if @options[:blank]
        @current_scope.children.empty?
      else
        !@current_scope.children.empty?
      end
    end

    def text_right?
      return true unless @options[:text]

      case text = @options[:text]
      when Regexp
        new_scope = @current_scope.css(':regexp()', NokogiriRegexpHelper.new(text))
        if new_scope.empty?
          @failure_message = format(MESSAGES[:expected_regexp], text.inspect, @tag, @document)
          false
        else
          @count = new_scope.count
          @failure_message_when_negated = format(MESSAGES[:unexpected_regexp], text.inspect, @tag, @document)
          true
        end
      else
        new_scope = @current_scope.css(':content()', NokogiriTextHelper.new(text, @options[:squeeze_text]))
        if new_scope.empty?
          @failure_message = format(MESSAGES[:expected_text], text, @tag, @document)
          false
        else
          @count = new_scope.count
          @failure_message_when_negated = format(MESSAGES[:unexpected_text], text, @tag, @document)
          true
        end
      end
    end

    protected

    def validate_options!
      validate_text_options!
      validate_count_presence!
      validate_count_when_set_min_max!
      validate_count_when_set_range!
    end

    def validate_text_options!
      # TODO: test these options validations
      if @options.key?(:blank) && @options[:blank] && @options.key?(:text) # rubocop:disable Style/GuardClause, Style/IfUnlessModifier
        raise ':text option is not accepted when :blank => true'
      end
    end

    def validate_count_presence!
      raise 'wrong :count specified' unless [Range, NilClass].include?(@options[:count].class) || @options[:count].is_a?(Integer)

      [:min, :minimum, :max, :maximum].each do |key|
        raise MESSAGES[:wrong_count_error] if @options.key?(key) && @options.key?(:count)
      end
    end

    def validate_count_when_set_min_max!
      raise MESSAGES[:min_max_error] if @options[:minimum] > @options[:maximum]
    rescue NoMethodError # nil > 4 # rubocop:disable Lint/HandleExceptions
    rescue ArgumentError # 2 < nil # rubocop:disable Lint/HandleExceptions
    end

    def validate_count_when_set_range!
      begin
        raise format(MESSAGES[:bad_range_error], @options[:count].to_s) if count_is_range_but_no_min?
      rescue ArgumentError, 'comparison of String with' # if @options[:count] == 'a'..'z' # rubocop:disable Lint/RescueType
        raise format(MESSAGES[:bad_range_error], @options[:count].to_s)
      end
    rescue TypeError # fix for 1.8.7 for 'rescue ArgumentError, "comparison of String with"' stroke
      raise format(MESSAGES[:bad_range_error], @options[:count].to_s)
    end

    def count_is_range_but_no_min?
      @options[:count] && @options[:count].is_a?(Range) &&
        (@options[:count].min.nil? || (@options[:count].min < 0))
    end

    def set_options
      @options[:minimum] ||= @options.delete(:min)
      @options[:maximum] ||= @options.delete(:max)

      @options[:text] = @options[:text].to_s if @options.key?(:text) && !@options[:text].is_a?(Regexp)

      if @options.key?(:seen) && !@options[:seen].is_a?(Regexp) # rubocop:disable Style/GuardClause
        @options[:text] = @options[:seen].to_s
        @options[:squeeze_text] = true
      end
    end
  end
end
