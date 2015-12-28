require 'spec_helper'

describe MauFeed::Parser do

  let(:source_url) { 'http://missionlocal.org/category/the-arts/feed/' }
  let(:feed_link) { 'http://twitter.com/sfmau' }

  subject(:feed) { MauFeed::Parser.new(source_url, feed_link) }

  let(:feed_content) { Nokogiri::HTML::DocumentFragment.parse(subject.feed_content) }

  describe '.new' do
    describe '#num_entries' do
      subject { super().num_entries }
      it { should eql MauFeed::Parser::NUM_POSTS }
    end

    describe '#strip_tags' do
      subject { super().strip_tags }
      it { should eq(true) }
    end

    describe '#truncate' do
      subject { super().truncate }
      it { should eq(true) }
    end

    describe '#css_class' do
      subject { super().css_class }
      it { should be_empty }
    end

    describe '#feed_link' do
      subject { super().feed_link }
      it { should eql feed_link }
    end

    describe '#url' do
      subject { super().send(:url) }
      it { should eql URI.parse(source_url) }
    end
  end

  it 'returns empty for a twitter feed that is invalid' do
    VCR.use_cassette('failed_twitter_feed') do
      expect(feed_content.css('.feed-entries')).to be_empty
    end
  end

  context 'for a valid feed' do
    let(:source_url) { 'http://reverberationradio.com/rss' }
    let(:feed_link) { 'http://reverberationradio.com' }
    it 'returns content for a valid feed' do
      VCR.use_cassette('reverberation_radio_rss') do
        expect(feed_content.css('.feed-entries .feed-header').inner_html).to include 'R e v e r b'
        expect(feed_content.css('.feed-entries .feedentry').inner_html).to be_present
        # no tags
        expect(feed_content.css('.feed-entries .feedtxt a')).to be_empty
        expect(feed_content.css('.feed-entries .feedtxt p')).to be_empty
        expect(feed_content.css('.feed-entries .feedtxt span')).to be_empty
      end
    end
  end
end
