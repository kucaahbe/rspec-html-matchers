RSpec::Matchers.define :have_tag do |tag,*options|
  require 'nokogiri'

  match do |document|
    options = options.shift
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
