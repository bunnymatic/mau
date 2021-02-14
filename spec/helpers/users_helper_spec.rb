require 'rails_helper'

describe UsersHelper do
  describe '.pretty_phone_number' do
    it 'makes phone number look pretty' do
      %w[14155551212 4155551212].each do |nice|
        expect(helper.pretty_phone_number(nice)).to eq '415.555.1212'
      end
    end

    it 'is robust against bad numbers or empties' do
      [nil, '', 'abc'].each do |bad|
        expect(helper.pretty_phone_number(bad)).to be_nil
      end
    end
  end
end
