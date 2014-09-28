require 'spec_helper'

describe MauFeed::Parser do

  let(:source_url) { 'https://twitter.com/statuses/user_timeline/62131363.json' }
  let(:feed_link) { 'http://twitter.com/sfmau' }

  subject(:feed) { MauFeed::Parser.new(source_url, feed_link) }

  let(:feed_content) { Nokogiri::HTML::DocumentFragment.parse(subject.feed_content) }

  describe '.new' do
    its(:num_entries) { should eql MauFeed::Parser::NUM_POSTS }
    its(:strip_tags) { should be_true }
    its(:truncate) { should be_true }
    its(:css_class) { should be_empty }
    its(:feed_link) { should eql feed_link }
    its(:url) { should eql URI.parse(source_url) }
    it{ expect(subject.send(:is_twitter?)).to be_true }
    context 'for not twitter feed' do
      let(:source_url) { 'http://missionlocal.org/category/the-arts/feed/' }
      it{ expect(subject.send(:is_twitter?)).to be_false }
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
