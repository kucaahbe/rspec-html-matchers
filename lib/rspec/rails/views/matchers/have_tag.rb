RSpec::Matchers.define :have_tag do |selector|
  require 'nokogiri'
  match do |document|
    parsed_html = Nokogiri::HTML(document)
    !parsed_html.css(selector).first.nil?
  end
end
