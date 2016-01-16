require 'rails_helper'

describe EmailSerializer do
  let(:email) { build(:email) }
  let(:serializer) { EmailSerializer.new(email) }

  it 'includes email' do
    expect(JSON::parse(serializer.to_json)['email']['email']).to eql email.email
  end
  it 'includes name' do
    expect(JSON::parse(serializer.to_json)['email']['name']).to eql email.name
  end

end
