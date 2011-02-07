require 'nokogiri'

module RSpec
  module Matchers

    class NokogiriMatcher#:nodoc:
      attr_reader :current_scope, :failure_message

      def initialize tag, options={}, &block
        @tag, @options, @block = tag, options, block

	if attrs = @options.delete(:with)
	  html_attrs_string=''
	  attrs.each_pair { |k,v| html_attrs_string << %Q{[#{k.to_s}='#{v.to_s}']} }
	  @tag << html_attrs_string
	end

	# TODO add min and max processing

	if @options.has_key?(:count)
	  raise 'wrong options' if @options.has_key?(:minimum) || @options.has_key?(:maximum)
	end
      end

      def matches?(document)

	if document.class==self.class
	  @current_scope = document.current_scope.css(@tag)
	else
	  @current_scope = Nokogiri::HTML(document).css(@tag)
	  @document = document
	end

	if tag_presents? #and count_right? and content_right?
	  @block.call if @block
	  true
	else
	  false
	end
      end

      private

      def tag_presents?
	if @current_scope.first
	  true
	else
	  @failure_message = %Q{expected following:\n#{@document}\nto have at least 1 element matching "#{@tag}", found 0.}
	  false
	end
      end

      def count_right?
	return true unless @options[:count] || @options[:minimum] || @options[:maximum]
	@actual_count = @current_scope.count
	case @options[:count]
	when Integer
	  @count_error_msg = @options[:count]
	  @actual_count == @options[:count]
	when Range
	  @count_error_msg = "from #{@options[:count].first} to #{@options[:count].last}"
	  @options[:count].member?(@actual_count)
	else
	  @wrong_formatted_count = true
	  false
	end
      end

      def content_right?
	if @options[:text]
	  @current_scope.any? {|node| node.content =~ Regexp.new(@options[:text]) }
	end
      end
    end

    # :call-seq:
    #   rendered.should have_tag(tag,options={},&block)
    #   rendered.should have_tag(tag,options={},&block) { with_tag(other_tag) }
    #   string.should have_tag(tag,options={},&block)
    #
    def have_tag tag,options={}, &block
      @__current_scope_for_nokogiri_matcher = NokogiriMatcher.new(tag,options, &block)
    end

    def with_tag tag, options={}, &block
      @__current_scope_for_nokogiri_matcher.should have_tag(tag, options, &block)
    end

    def without_tag tag, options={}, &block
      @__current_scope_for_nokogiri_matcher.should_not have_tag(tag, options, &block)
    end

  end
end
