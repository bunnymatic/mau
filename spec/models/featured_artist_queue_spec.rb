require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeaturedArtistQueue do
  fixtures :users
  before do
    # simulate migration 
    ActiveRecord::Base.transaction do 
      sql = "delete from featured_artist_queue"
      ActiveRecord::Base.connection.execute sql
      sql = "insert into featured_artist_queue(artist_id, position) (select id, rand() from users where type='Artist' and activated_at is not null and state='active')"
      ActiveRecord::Base.connection.execute sql
    end
  end

  describe '#current_entry' do
    it "returns the artist with the first position" do
      FeaturedArtistQueue.current_entry == FeaturedArtistQueue.all.sort{ |a,b| a.position <=> b.position }.first.artist_id
    end
    it "calling it multiple times only invokes next_entry once" do
      # let it be called once, which will trigger the update, then it shouldn't be called again
      FeaturedArtistQueue.current_entry
      FeaturedArtistQueue.expects(:next_entry).never
      FeaturedArtistQueue.current_entry.should == FeaturedArtistQueue.current_entry
    end
  end

  describe '#next_entry' do
    before do
      @a = FeaturedArtistQueue.next_entry.artist
    end
    it "returns an artist" do
      @a.should be_a_kind_of(Artist)
    end
    it "returns the artist with the first position" do
      @a.id.should == FeaturedArtistQueue.all.sort{ |a,b| a.position <=> b.position }.first.artist_id
    end
    it "marks the entry as featured with todays date" do
      FeaturedArtistQueue.find_by_artist_id(@a.id).featured.should_not be_nil
    end
    it "calling it again within a week gives you the same artist" do
      FeaturedArtistQueue.next_entry.artist_id.should == @a.id
    end
    it "calling it after a week should give you the next artist" do
      Time.stubs(:now => Time.now() + 2.weeks)
      a = FeaturedArtistQueue.next_entry.artist
      a.id.should == FeaturedArtistQueue.all.sort{ |a,b| a.position <=> b.position }[1].artist_id
    end
    describe "after everyone has been featured" do
      before do
        sql = "update featured_artist_queue set featured='#{(Time.now - 10.weeks).strftime('%M/%D/%Y')}'"
        ActiveRecord::Base.connection.execute(sql);
        FeaturedArtistQueue.next_entry
      end
      it "it unfeatures everyone and starts over" do
        FeaturedArtistQueue.featured.count.should == 1
      end
    end
  end
  describe "activating an artist" do
    it "adds that artist to the featured artist queue" do
      pend = users(:pending_artist)
      expect{ pend.activate! }.to change(FeaturedArtistQueue, :count).by(1)
      FeaturedArtistQueue.find_by_artist_id(pend.id).should_not be_nil
    end
  end

  describe 'named scopes' do
    before do
      FeaturedArtistQueue.all.each_with_index do |fa, idx| 
        if (idx % 2) == 0 
          fa.featured = Time.now - idx.weeks - 1.day
          fa.save!
        end
      end
      FeaturedArtistQueue.count.should > 1
    end
    describe "#featured" do
      it "only returns entrys where featured is not nil" do
        FeaturedArtistQueue.featured.any?{|fa| fa.featured == nil}.should be_false      
      end
    end
    describe "#not_yet_featured" do
      it "returns only entries where featured is nil" do
        FeaturedArtistQueue.not_yet_featured.all?{|fa| fa.featured == nil}.should be_true
      end
    end
    describe "default scope" do
      it "returns items ordered by position" do
        FeaturedArtistQueue.all.map(&:position).should == FeaturedArtistQueue.all.sort{|a,b| a.position <=> b.position}.map(&:position)
      end
    end
  end

end
