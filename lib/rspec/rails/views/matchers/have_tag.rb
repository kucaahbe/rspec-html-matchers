require 'nokogiri'

module RSpec
  module Matchers

    class NokogiriMatcher#:nodoc:

      def initialize tag, options={}, &block
        @tag, @options, @block = tag, options, block
      end

      def matches?(document,&block)
	parsed_html = Nokogiri::HTML(document)
	@current_scope = parsed_html.css(@tag)

	tag_in_scope? || (return false)
	count_right? || (return false) if @options.has_key?(:count)
	text_presents? || (return false) if @options.has_key?(:text)
	true
      end

      private

      def tag_in_scope?
	!@current_scope.first.nil?
      end

      def count_right?
	@current_scope.count == @options[:count]
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
      NokogiriMatcher.new(tag,options, &block)
    end

    def with_tag tag, options={}, &block
      pending
    end

    def without_tag tag, options={}, &block
      pending
    end

  end
end
