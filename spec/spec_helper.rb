require 'rspec/rails/views/matchers'

module RenderedHelper
  def rendered
    @rendered ||= File.open(File.join(File.dirname(__FILE__),'rendered_view.html')) { |f| f.read }
  end
end

RSpec.configure do |config|
  config.include RenderedHelper
end
