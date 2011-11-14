module Helpers

  def asset name
    IO.read(File.join( File.dirname(__FILE__), '..', '..', 'assets', "#{name}.html" ))
  end

  def raise_spec_error msg
    raise_error RSpec::Expectations::ExpectationNotMetError, msg
  end

end
