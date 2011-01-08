require 'nokogiri'

module RSpec
  module Matchers
    def have_tag(tag,options={},&block)
      Matcher.new :have_tag, tag, options, block do |_tag_, _options_, _block_|

	match do |document|
	  parsed_html = Nokogiri::HTML(document)
	  node_set = parsed_html.css(tag)

	  result = [!node_set.first.nil?]
	  if options
	    result << (node_set.count == options[:count]) if options.has_key?(:count)
	    result << node_set.any? {|node| node.content =~ Regexp.new(options[:text]) } if options.has_key?(:text)
	  end
	  result.all? {|boolean| boolean==true }
	end
      end
    end
  end
end
