require 'spec_helper'


describe ArtistFeed do
  fixtures :artist_feeds

  it{ should validate_presence_of(:url) }
  it{ should validate_presence_of(:feed) }
  it{ should validate_uniqueness_of(:feed) }
  
  it{ should ensure_length_of(:url).is_at_least(5).is_at_most(255) }
  it{ should ensure_length_of(:feed).is_at_least(5).is_at_most(255) }

  describe 'named scopes' do
    describe 'active' do
      it 'returns only active items' do
        ArtistFeed.all.all?{|a| a.active?}.should == false
        ArtistFeed.active.all.all?{|a| a.active?}.should == true
      end
    end
  end

end
