require 'rails_helper'

describe EmailSerializer do
  let(:email) { build(:email) }
  subject(:serialized) do
    serialize(email, described_class)
  end

  it 'includes type: email' do
    expect(serialized[:data][:type]).to eql :email
  end
  it 'includes email' do
    expect(serialized[:data][:attributes][:email]).to eql email.email
  end
  it 'includes name' do
    expect(serialized[:data][:attributes][:name]).to eql email.name
  end
end
