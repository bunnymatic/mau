require 'spec_helper'

describe FeedParser do

  let(:source_url) { 'http://twitter.com/statuses/user_timeline/62131363.json' }
  let(:feed_link) { 'http://twitter.com/sfmau' }

  subject(:feed) { FeedParser.new(source_url, feed_link) }
  describe '.new' do
    its(:num_entries) { should eql FeedParser::NUM_POSTS }
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
end
