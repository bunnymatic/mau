require 'rails_helper'

describe YoutubeUrlValidator do
  subject do
    Class.new do
      def self.name
        'UrlValidatorTestModel'
      end
      include ActiveModel::Validations
      attr_accessor :video_url

      validates :video_url, youtube_url: true
    end.new
  end

  describe 'for a valid youtube url' do
    valid_youtube_urls = [
      'https://www.youtube.com/watch?v=23ihawJKZcE&feature=featured',
      'https://www.youtube.com/watch?v=23ihawJKZcE',
      'http://www.youtube.com/watch?v=23ihawJKZcE',
      'https://youtube.com/watch?v=23ihawJKZcE',
      'http://youtube.com/watch?v=23ihawJKZcE',
      'https://m.youtube.com/watch?v=23ihawJKZcE',
      'http://m.youtube.com/watch?v=23ihawJKZcE',
      'https://www.youtube.com/watch?v=T1j1_aeK6WA',
    ]

    valid_youtube_urls.each do |test|
      it "should be valid for url like #{test}" do
        subject.video_url = test
        subject.validate
        expect(subject.errors).to have(0).errors, "#{test} is not a valid youtube url #{subject.errors.full_messages}"
      end
    end
  end

  describe 'for valid urls that are *not* youtube urls' do
    invalid_youtube_urls = [
      'http://google.com',
      'https://abc.def.com/here-we-go',
      'https://abc.def.com/here-we-go?this#that',
      'https://username:password@abc.def.com/here-we-go?this#that',
    ]
    invalid_youtube_urls.each do |test|
      it "should not allow valid urls that are not youtube urls like #{test}" do
        subject.video_url = test
        subject.validate
        expect(subject.errors[:video_url]).to include('does not look like a Youtube link.')
      end
    end
  end

  describe 'for empty values' do
    it 'should allow empty' do
      valid_urls = [
        '',
        nil,
        '       ',
      ]
      valid_urls.each do |test|
        subject.video_url = test
        subject.validate
        expect(subject.errors).to have(0).errors, "#{test} is invalid #{subject.errors.full_messages}"
      end
    end
  end

  describe 'for invalid urls' do
    invalid_urls = [
      '1  AAA   5551212',
      'httpccc',
      'httpx://ccc.com',
      'https://username@password:abc.def.com/here-we-go?this#that',
    ]
    invalid_urls.each do |test|
      it "should not allow invalid urls like #{test}" do
        subject.video_url = test
        subject.validate
        expect(subject.errors[:video_url]).to include('is not a valid URL. Did you remember including http:// or https:// at the beginning?')
      end
    end
  end
end
