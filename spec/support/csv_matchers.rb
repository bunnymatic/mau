# frozen_string_literal: true
RSpec::Matchers.define :be_csv_type do
  match do |actual|
    expect(actual.content_type.to_s).to eql 'text/csv'
  end

  failure_message do |actual|
    "expected #{actual.content_type} to be 'text/csv'"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.content_type} not to be 'text/csv'"
  end

  description do
    'be a CSV response'
  end
end
