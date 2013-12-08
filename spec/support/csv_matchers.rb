RSpec::Matchers.define :be_csv_type do
  match do |actual|
    actual.content_type.to_s.should eql 'text/csv'
  end

  failure_message_for_should do |actual|
    "expected #{actual.content_type} to be 'text/csv'"
  end

  failure_message_for_should_not do |actual|
    "expected #{actual.content_type} not to be 'text/csv'"
  end

  description do
    'be a CSV response'
  end
end

