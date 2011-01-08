require 'nokogiri'

module RSpec
  module Matchers

    class NokogiriMatcher#:nodoc:
      attr_reader :current_scope

      def initialize tag, options={}, &block
        @tag, @options, @block = tag, options, block
      end

      def matches?(document)
	if document.class==self.class
	  @current_scope = document.current_scope.css(@tag)
	else
	  @current_scope = Nokogiri::HTML(document).css(@tag)
	end

	tag_in_scope? || (return false)
	count_right? || (return false) if @options.has_key?(:count)
	text_presents? || (return false) if @options.has_key?(:text)

	@block.call if @block
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
