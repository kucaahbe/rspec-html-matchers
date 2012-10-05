require 'rspec/core'

if defined?(SimpleCov)
  SimpleCov.start do
    add_group 'Main', '/lib/'
  end
end

require 'rspec-html-matchers'

SPEC_DIR = File.dirname(__FILE__)

module AssetHelpers

  def asset name
    let :rendered do
      IO.read File.join(SPEC_DIR,"assets/#{name}.html")
    end
  end

end

module CustomHelpers

  def raise_spec_error msg
    raise_error RSpec::Expectations::ExpectationNotMetError, msg
  end

end

RSpec.configure do |config|
  config.extend  AssetHelpers
  config.include CustomHelpers
end
