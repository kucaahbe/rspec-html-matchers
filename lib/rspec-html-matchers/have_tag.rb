# encoding: UTF-8
# frozen_string_literal: true

require 'nokogiri'

module RSpecHtmlMatchers
  # @api
  # @private
  class HaveTag # rubocop:disable Metrics/ClassLength
    DESCRIPTIONS = {
      :have_at_least_1 => %(have at least 1 element matching "%s"),
      :have_n          => %(have %i element(s) matching "%s"),
    }.freeze

    MESSAGES = {
      :expected_tag         => %(expected following:\n%s\nto #{DESCRIPTIONS[:have_at_least_1]}, found 0.),
      :unexpected_tag       => %(expected following:\n%s\nto NOT have element matching "%s", found %s.),

      :expected_count       => %(expected following:\n%s\nto #{DESCRIPTIONS[:have_n]}, found %s.),
      :unexpected_count     => %(expected following:\n%s\nto NOT have %i element(s) matching "%s", but found.),

      :expected_btw_count   => %(expected following:\n%s\nto have at least %i and at most %i element(s) matching "%s", found %i.),
      :unexpected_btw_count => %(expected following:\n%s\nto NOT have at least %i and at most %i element(s) matching "%s", but found %i.),

      :expected_at_most     => %(expected following:\n%s\nto have at most %i element(s) matching "%s", found %i.),
      :unexpected_at_most   => %(expected following:\n%s\nto NOT have at most %i element(s) matching "%s", but found %i.),

      :expected_at_least    => %(expected following:\n%s\nto have at least %i element(s) matching "%s", found %i.),
      :unexpected_at_least  => %(expected following:\n%s\nto NOT have at least %i element(s) matching "%s", but found %i.),

      :expected_blank       => %(expected following template to contain empty tag %s:\n%s),
      :unexpected_blank     => %(expected following template to contain tag %s with other tags:\n%s),

      :expected_regexp      => %(%s regexp expected within "%s" in following template:\n%s),
      :unexpected_regexp    => %(%s regexp unexpected within "%s" in following template:\n%s\nbut was found.),

      :expected_text        => %("%s" expected within "%s" in following template:\n%s),
      :unexpected_text      => %("%s" unexpected within "%s" in following template:\n%s\nbut was found.),

      :wrong_count_error    => %(:count with :minimum or :maximum has no sence!),
      :min_max_error        => %(:minimum should be less than :maximum!),
      :bad_range_error      => %(Your :count range(%s) has no sence!),
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
      organize_options!
    end

    attr_reader :failure_message
    attr_reader :failure_message_when_negated
    attr_reader :current_scope

    def matches? src, &block
      @block = block if block

      src = src.html if defined?(Capybara::Session) && src.is_a?(Capybara::Session)

      case src
      when String
        parent_scope = Nokogiri::HTML(src)
        @document    = src
      else
        parent_scope  = src.current_scope
        @document     = parent_scope.to_html
      end

      @current_scope = begin
                         parent_scope.css(tag)
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

    def description
      # TODO: should it be more complicated?
      if options.key?(:count)
        format(DESCRIPTIONS[:have_n], options[:count], tag)
      else
        DESCRIPTIONS[:have_at_least_1] % tag
      end
    end

    private

    attr_reader :tag
    attr_reader :options
    attr_reader :document

    def classes_to_selector classes
      case classes
      when Array
        classes.join('.')
      when String
        classes.gsub(/\s+/, '.')
      end
    end

    def tag_presents?
      if current_scope.first
        @count = current_scope.count
        match_succeeded! :unexpected_tag, document, tag, @count
      else
        match_failed! :expected_tag, document, tag
      end
    end

    def count_right? # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      case options[:count]
      when Integer
        if @count == options[:count]
          match_succeeded! :unexpected_count, document, @count, tag
        else
          match_failed! :expected_count, document, options[:count], tag, @count
        end
      when Range
        if options[:count].member? @count
          match_succeeded! :unexpected_btw_count, document, options[:count].min, options[:count].max, tag, @count
        else
          match_failed! :expected_btw_count, document, options[:count].min, options[:count].max, tag, @count
        end
      when nil
        if options[:maximum]
          if @count <= options[:maximum]
            match_succeeded! :unexpected_at_most, document, options[:maximum], tag, @count
          else
            match_failed! :expected_at_most, document, options[:maximum], tag, @count
          end
        elsif options[:minimum]
          if @count >= options[:minimum]
            match_succeeded! :unexpected_at_least, document, options[:minimum], tag, @count
          else
            match_failed! :expected_at_least, document, options[:minimum], tag, @count
          end
        else
          true
        end
      end
    end

    def proper_content?
      if options.key?(:blank)
        maybe_empty?
      else
        text_right?
      end
    end

    def maybe_empty?
      if options[:blank] && current_scope.children.empty?
        match_succeeded! :unexpected_blank, tag, document
      else
        match_failed! :expected_blank, tag, document
      end
    end

    def text_right?
      return true unless options[:text]

      case text = options[:text]
      when Regexp
        new_scope = current_scope.css(':regexp()', NokogiriRegexpHelper.new(text))
        if new_scope.empty?
          match_failed! :expected_regexp, text.inspect, tag, document
        else
          @count = new_scope.count
          match_succeeded! :unexpected_regexp, text.inspect, tag, document
        end
      else
        new_scope = current_scope.css(':content()', NokogiriTextHelper.new(text, options[:squeeze_text]))
        if new_scope.empty?
          match_failed! :expected_text, text, tag, document
        else
          @count = new_scope.count
          match_succeeded! :unexpected_text, text, tag, document
        end
      end
    end

    def validate_options!
      validate_html_body_tags!
      validate_text_options!
      validate_count_presence!
      validate_count_when_set_min_max!
      validate_count_when_set_range!
    end

    # here is a demo:
    #   irb(main):009:0> Nokogiri::HTML('<p>asd</p>').xpath('//html')
    #   => [#<Nokogiri::XML::Element:0x3fea02cd3f58 name="html" children=[#<Nokogiri::XML::Element:0x3fea02cd37c4 name="body" children=[#<Nokogiri::XML::Element:0x3fea02cd34e0 name="p" children=[#<Nokogiri::XML::Text:0x3fea02cd3134 "asd">]>]>]>]
    #   irb(main):010:0> Nokogiri::HTML('<p>asd</p>').xpath('//body')
    #   => [#<Nokogiri::XML::Element:0x3fea02ce3df4 name="body" children=[#<Nokogiri::XML::Element:0x3fea02ce3a70 name="p" children=[#<Nokogiri::XML::Text:0x3fea02ce350c "asd">]>]>]
    #   irb(main):011:0> Nokogiri::HTML('<p>asd</p>').xpath('//p')
    #   => [#<Nokogiri::XML::Element:0x3fea02cf3754 name="p" children=[#<Nokogiri::XML::Text:0x3fea02cf2f98 "asd">]>]
    #   irb(main):012:0> Nokogiri::HTML('<p>asd</p>').xpath('//a')
    #   => []
    def validate_html_body_tags!
      if %w[html body].include?(tag) && options.empty?
        raise ArgumentError, 'matching <html> and <body> tags without specifying additional options does not work, see: https://github.com/kucaahbe/rspec-html-matchers/pull/75'
      end
    end

    def validate_text_options!
      # TODO: test these options validations
      if options.key?(:blank) && options[:blank] && options.key?(:text) # rubocop:disable Style/GuardClause, Style/IfUnlessModifier
        raise ':text option is not accepted when :blank => true'
      end
    end

    def validate_count_presence!
      raise 'wrong :count specified' unless [Range, NilClass].include?(options[:count].class) || options[:count].is_a?(Integer)

      [:min, :minimum, :max, :maximum].each do |key|
        raise MESSAGES[:wrong_count_error] if options.key?(key) && options.key?(:count)
      end
    end

    def validate_count_when_set_min_max!
      raise MESSAGES[:min_max_error] if options[:minimum] > options[:maximum]
    rescue NoMethodError # nil > 4 # rubocop:disable Lint/HandleExceptions
    rescue ArgumentError # 2 < nil # rubocop:disable Lint/HandleExceptions
    end

    def validate_count_when_set_range!
      begin
        raise format(MESSAGES[:bad_range_error], options[:count].to_s) if count_is_range_but_no_min?
      rescue ArgumentError, 'comparison of String with' # if options[:count] == 'a'..'z' # rubocop:disable Lint/RescueType
        raise format(MESSAGES[:bad_range_error], options[:count].to_s)
      end
    rescue TypeError # fix for 1.8.7 for 'rescue ArgumentError, "comparison of String with"' stroke
      raise format(MESSAGES[:bad_range_error], options[:count].to_s)
    end

    def count_is_range_but_no_min?
      options[:count].is_a?(Range) &&
        (options[:count].min.nil? || (options[:count].min < 0))
    end

    def organize_options!
      @options[:minimum] ||= @options.delete(:min)
      @options[:maximum] ||= @options.delete(:max)

      @options[:text] = @options[:text].to_s if @options.key?(:text) && !@options[:text].is_a?(Regexp)

      if @options.key?(:seen) && !@options[:seen].is_a?(Regexp) # rubocop:disable Style/GuardClause
        @options[:text] = @options[:seen].to_s
        @options[:squeeze_text] = true
      end
    end

    def match_succeeded! message, *args
      @failure_message_when_negated = format MESSAGES[message], *args
      true
    end

    def match_failed! message, *args
      @failure_message = format MESSAGES[message], *args
      false
    end
  end
end
