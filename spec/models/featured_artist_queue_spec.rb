require 'spec_helper'

describe FeaturedArtistQueue do

  let(:artists) { FactoryGirl.create_list :artist, 5, :with_studio, :with_art }
  let(:pending_artist) { FactoryGirl.create :artist, :pending }
  before do
    # simulate migration
    artists
    ActiveRecord::Base.transaction do
      sql = "delete from featured_artist_queue"
      ActiveRecord::Base.connection.execute sql
      sql = "insert into featured_artist_queue(artist_id, position)"+
        " (select id, rand() from users where type='Artist' and activated_at is not null and state='active')"
      ActiveRecord::Base.connection.execute sql
    end
  end

  let(:queue) { FeaturedArtistQueue.all }
  let(:sorted_queue) { queue.sort_by(&:position) }

  describe '#current_entry' do
    let(:current_entry) { FeaturedArtistQueue.current_entry }
    it "returns the artist with the first position" do
      expect(current_entry).to eql sorted_queue.first
    end
    it "calling it multiple times only invokes next_entry once" do
      # let it be called once, which will trigger the update, then it shouldn't be called again
      FeaturedArtistQueue.current_entry
      expect(FeaturedArtistQueue).to receive(:next_entry).never
      expect(FeaturedArtistQueue.current_entry).to eql FeaturedArtistQueue.current_entry
    end
  end

  describe '#next_entry' do
    let(:next_entry) { FeaturedArtistQueue.next_entry.artist }
    it "returns an artist" do
      expect(next_entry).to be_a_kind_of(Artist)
    end
    it "returns the artist with the first position" do
      expect(next_entry.id).to eql sorted_queue.first.artist_id
    end
    it "marks the entry as featured with todays date" do
      expect(FeaturedArtistQueue.find_by_artist_id(next_entry.id).featured).not_to be_nil
    end
    it "calling it again within a week gives you the same artist" do
      expect(FeaturedArtistQueue.next_entry.artist_id).to eql next_entry.id
    end
    it "calling it after a week should give you the next artist" do
      next_entry
      t = Time.zone.now + 2.weeks
      Time.stub(:now => t)
      Time.zone.stub(:now => t)
      a = FeaturedArtistQueue.next_entry.artist
      expect(a.id).to eql FeaturedArtistQueue.all.sort{ |a,b| a.position <=> b.position }[1].artist_id
    end
    describe "after everyone has been featured" do
      before do
        t = (Time.zone.now - 10.weeks).strftime('%Y-%m-%d')
        sql = "update featured_artist_queue set featured='#{t}'"
        ActiveRecord::Base.connection.execute(sql);
        FeaturedArtistQueue.next_entry
      end
      it "it unfeatures everyone and starts over" do
        expect(FeaturedArtistQueue.featured.count).to eql 1
      end
    end
  end
  describe "activating an artist" do
    it "adds that artist to the featured artist queue" do
      expect{ pending_artist.activate! }.to change(FeaturedArtistQueue, :count).by(1)
      expect(FeaturedArtistQueue.find_by_artist_id(pending_artist.id)).not_to be_nil
    end
  end

  describe 'named scopes' do
    before do
      FeaturedArtistQueue.all.each_with_index do |fa, idx|
        if (idx % 2) == 0
          fa.update_attribute :featured, Time.zone.now - idx.weeks - 1.day
        end
      end
      expect(FeaturedArtistQueue.count).to be > 1
    end
    describe "#featured" do
      it "only returns entrys where featured is not nil" do
        expect(FeaturedArtistQueue.featured.any?{|fa| fa.featured == nil}).to eq false
      end
    end
    describe "#not_yet_featured" do
      it "returns only entries where featured is nil" do
        expect(FeaturedArtistQueue.not_yet_featured.all?{|fa| fa.featured == nil}).to eq(true)
      end
    end
    describe "default scope" do
      it "returns items ordered by position" do
        expect(FeaturedArtistQueue.by_position.map(&:position)).to be_monotonically_increasing
      end
    end
  end

end
