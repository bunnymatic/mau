require 'rails_helper'

describe 'PhoneNumberValidator' do
  subject do
    Class.new do
      def self.name
        'PhoneNumberValidatorTestModel'
      end
      include ActiveModel::Validations
      attr_accessor :phone

      validates :phone, phone_number: true
    end.new
  end

  it 'should allow valid phone numbers' do
    valid_numbers = [
      '4155551212',
      '14155551212',
      '1 (415) 555 1212',
      '1 (415) 555-1212',
      '+1 (415) 555-1212',
      '415A5551212',
    ]
    valid_numbers.each do |test|
      subject.phone = test
      subject.validate
      expect(subject.errors).to have(0).errors, "#{test} is invalid #{subject.errors.full_messages}"
    end
  end

  it 'should allow empty' do
    valid_numbers = [
      '',
      nil,
      '       ',
    ]
    valid_numbers.each do |test|
      subject.phone = test
      subject.validate
      expect(subject.errors).to have(0).errors, "#{test} is invalid #{subject.errors.full_messages}"
    end
  end
  it 'should not allow invalid phone numbers' do
    valid_numbers = [
      '1AAA5551212',
      '1 (415) 55512',
      '1 (415 555-121a',
      'abc123+1 (415) 555!1212',
      '1 415.111.2222 ext 1234',
    ]
    valid_numbers.each do |test|
      subject.phone = test
      subject.validate
      expect(subject.errors[:phone]).to include('must be 10 or 11 digits'), "#{test} is responding like a valid phone number which it shouldn't"
    end
  end
end
