require 'rspec/rails/views/matchers'

module RenderedHelper
  def render_html html
    @rendered = html
  end

  def rendered
    @rendered
  end
end

RSpec.configure do |config|
  config.include RenderedHelper
end
