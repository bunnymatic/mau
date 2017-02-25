# frozen_string_literal: true
require 'rails_helper'

module MauFanSpecHelper
  def valid_user_attributes
    { login: 'joe@bloggs.com',
      email: 'joe@bloggs.com',
      password: 'abcdefghij',
      password_confirmation: 'abcdefghij' }
  end
end

describe MauFan do
  include MauFanSpecHelper
  describe '#new' do
    let(:fan_attrs) { valid_user_attributes }
    let(:new_fan) { u = MauFan.new(fan_attrs); u.valid?; u }

    context 'with valid attributes' do
      it 'should be valid fan' do
        expect(new_fan).to be_valid
      end
    end

    context 'with nothing' do
      let(:fan_attrs) { {} }

      it 'should not be valid' do
        expect(new_fan).to_not be_valid
        expect(new_fan).to have(1).error_on(:password)
        expect(new_fan).to have(1).error_on(:password_confirmation)
        expect(new_fan).to have_at_least(2).error_on(:login)
        expect(new_fan).to have_at_least(4).error_on(:email)
      end
    end

    it "should not allow '   ' for email" do
      fan = new_fan
      fan.email = '  '
      expect(fan).to_not be_valid
      expect(fan).to have_at_least(1).error_on(:email)
    end

    it 'should not allow blow@ for email' do
      fan = new_fan
      fan.email = 'blow@'
      expect(fan).to_not be_valid
      expect(fan).to have_at_least(1).error_on(:email)
    end
  end
end
