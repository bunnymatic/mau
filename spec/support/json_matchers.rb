RSpec::Matchers.define :be_json do
  match do |actual|
    expect(actual.content_type.to_s).to eql 'application/json'
  end

  failure_message do |actual|
    "expected #{actual.content_type} to be 'application/json'"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.content_type} not to be 'application/json'"
  end

  description do
    'be a JSON response'
  end
end
