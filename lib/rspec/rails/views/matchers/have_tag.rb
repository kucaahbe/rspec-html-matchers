require 'nokogiri'

module RSpec
  module Matchers

    class NokogiriMatcher#:nodoc:

      def initialize tag, options={}, &block
        @tag, @options, @block = tag, options, block
      end

      def matches?(document,&block)
	parsed_html = Nokogiri::HTML(document)
	node_set = parsed_html.css(@tag)

	result = [!node_set.first.nil?]
	if @options
	  result << (node_set.count == @options[:count]) if @options.has_key?(:count)
	  result << node_set.any? {|node| node.content =~ Regexp.new(@options[:text]) } if @options.has_key?(:text)
	end
	result.all? {|boolean| boolean==true }
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
