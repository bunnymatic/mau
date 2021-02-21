require 'rails_helper'

describe UrlValidator do
  subject do
    Class.new do
      def self.name
        'UrlValidatorTestModel'
      end
      include ActiveModel::Validations
      attr_accessor :url

      validates :url, url: true
    end.new
  end

  valid_urls = [
    'http://google.com',
    'https://abc.def.com/here-we-go',
    'https://abc.def.com/here-we-go?this#that',
    'https://username:password@abc.def.com/here-we-go?this#that',
  ]
  valid_urls.each do |test|
    it "should allow valid url like #{test}" do
      subject.url = test
      subject.validate
      expect(subject.errors).to have(0).errors, "#{test} is invalid #{subject.errors.full_messages}"
    end
  end

  it 'should allow empty' do
    valid_urls = [
      '',
      nil,
      '       ',
    ]
    valid_urls.each do |test|
      subject.url = test
      subject.validate
      expect(subject.errors).to have(0).errors, "#{test} is invalid #{subject.errors.full_messages}"
    end
  end

  invalid_urls = [
    '1  AAA   5551212',
    'httpccc',
    'httpx://ccc.com',
    'https://username@password:abc.def.com/here-we-go?this#that',
  ]
  invalid_urls.each do |test|
    it "should not allow invalid urls like #{test}" do
      subject.url = test
      subject.validate
      expect(subject.errors[:url]).to include('is not a valid URL. Did you remember including http:// or https:// at the beginning?')
    end
  end
end
