require 'spec_helper'


describe ArtistFeed do
  fixtures :artist_feeds
  describe 'named scopes' do
    describe 'active' do
      it 'returns only active items' do
        ArtistFeed.all.all?{|a| a.active?}.should == false
        ArtistFeed.active.all.all?{|a| a.active?}.should == true
      end
    end
  end

end
