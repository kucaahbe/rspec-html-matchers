require 'rspec/core'
require 'rspec/expectations'

if defined?(SimpleCov)
  SimpleCov.start do
    add_group 'Main', '/lib/'
    add_filter "/spec/"
  end
end

require 'rspec-html-matchers'

module AssetHelpers

  ASSETS = File.expand_path('../fixtures/%s.html',__FILE__)

  def asset name
    asset_content = fixtures[name] ||= IO.read(ASSETS%name)
    let(:rendered) { asset_content }
  end

  private

  def fixtures
    @assets ||= {}
  end

end

RSpec::Matchers.define :raise_spec_error do |expected_exception_msg|
  define_method :actual_msg do
    @actual_msg
  end

  define_method :catched_exception do
    @catched_exception
  end

  match do |block|
    begin
      block.call
      false
    rescue RSpec::Expectations::ExpectationNotMetError => rspec_error
      @actual_msg = rspec_error.message

      case expected_exception_msg
      when String
        actual_msg == expected_exception_msg
      when Regexp
        actual_msg =~ expected_exception_msg
      end
    rescue StandardError => e
      @catched_exception = e
      false
    end
  end

  failure_message_for_should do |block|
    if actual_msg
<<MSG
expected RSpec::Expectations::ExpectationNotMetError with message:
#{expected_exception_msg}

got:
#{actual_msg}

Diff:
#{RSpec::Expectations::Differ.new.diff_as_string(actual_msg,expected_exception_msg.to_s)}
MSG
    elsif catched_exception
      "expected RSpec::Expectations::ExpectationNotMetError, but was #{catched_exception.inspect}"
    else
      "expected RSpec::Expectations::ExpectationNotMetError, but was no exception"
    end
  end
end

RSpec.configure do |config|

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.filter_run_excluding wip: true

  config.extend  AssetHelpers
end
