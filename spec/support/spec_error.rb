def raise_spec_error msg
  raise_error RSpec::Expectations::ExpectationNotMetError, msg
end
