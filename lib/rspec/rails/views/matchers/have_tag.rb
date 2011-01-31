require 'nokogiri'

module RSpec
  module Matchers

    class NokogiriMatcher#:nodoc:
      attr_reader :current_scope

      def initialize tag, options={}, &block
        @tag, @options, @block = tag, options, block
      end

      def matches?(document)
	if @options.has_key?(:with)
	  html_attrs_string=''
	  @options[:with].each_pair { |k,v| html_attrs_string << %Q{[#{k.to_s}="#{v.to_s}"]} }
	  @tag << html_attrs_string
	end

	if document.class==self.class
	  @current_scope = document.current_scope.css(@tag)
	else
	  @current_scope = Nokogiri::HTML(document).css(@tag)
	  @document = document
	end

	tag_in_scope? || (return @tags_found=false)
	count_right? || (return @count_right=false) if @options.has_key?(:count)
	text_presents? || (return false) if @options.has_key?(:text)

	@block.call if @block
	true
      end

      def failure_message
	case false
	when @tags_found
	  "expected following:\n#{@document}\nto include #{Nokogiri::CSS.xpath_for(@tag)}"
	when @count_right
	  "TODO"
	end
      end

      private

      def tag_in_scope?
	!@current_scope.first.nil?
      end

      def count_right?
	actual_count = @current_scope.count
	case @options[:count]
	when Integer
	  actual_count == @options[:count]
	when Range
	  @options[:count].member?(actual_count)
	when String
	  case @options[:count]
	  when /^>(\d+)$/
	    actual_count > $1.to_i
	  when /^>=(\d+)$/
	    actual_count >= $1.to_i
	  when /^<(\d+)$/
	    actual_count < $1.to_i
	  when /^<=(\d+)$/
	    actual_count <= $1.to_i
	  end
	else
	  @wrong_formatted_count = true
	  false
	end
      end

      def text_presents?
	@current_scope.any? {|node| node.content =~ Regexp.new(@options[:text]) }
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
