# frozen_string_literal: true

require 'rails_helper'

describe MauFan do
  describe '#new' do
    let(:fan_attrs) { attributes_for(:mau_fan) }
    let(:new_fan) { described_class.new(fan_attrs) }

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
