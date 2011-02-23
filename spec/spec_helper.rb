require 'rspec2-rails-views-matchers'

# Requires supporting files with custom matchers and macros, etc,
# # in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

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
