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
	@options[:minimum] ||= @options.delete(:min)
	@options[:maximum] ||= @options.delete(:max)
      end

      def matches?(document)

	if document.class==self.class
	  @current_scope = document.current_scope.css(@tag)
	  @document = document.current_scope.to_html
	else
	  @current_scope = Nokogiri::HTML(document).css(@tag)
	  @document = document
	end

	if tag_presents? and count_right? and content_right?
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
