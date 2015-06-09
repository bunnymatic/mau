require 'spec_helper'
describe Admin::StatsController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:artist) { FactoryGirl.create(:artist, :active) }
  let(:artist2) { FactoryGirl.create(:artist, :active) }
  before do
    login_as admin
  end

  describe "json endpoints" do
    [:user_visits_per_day, :artists_per_day, :favorites_per_day, :art_pieces_per_day, :os_signups].each do |endpoint|
      describe endpoint do
        before do
          xhr :get, endpoint
        end
        it_should_behave_like 'successful json'
        it "json is ready for flotr" do
          j = JSON.parse(response.body)
          j.keys.should include 'series'
          j.keys.should include 'options'
        end
      end
    end
  end

  describe "helper methods" do
    let(:art_pieces_per_day) { Admin::StatsController.new.send(:compute_art_pieces_per_day) }
    let(:artists_per_day) { Admin::StatsController.new.send(:compute_artists_per_day) }
    before do
      Timecop.freeze
      FactoryGirl.create(:artist, :active, :with_art)
      3.times.each do |n|
        Timecop.travel (1+n).days.ago
        FactoryGirl.create(:artist, :active, :with_art)
      end
      artists_per_day
      art_pieces_per_day
    end
    after do
      Timecop.return
    end

    describe "compute_artists_per_day" do
      it "returns an array" do
        artists_per_day.should be_a_kind_of(Array)
        artists_per_day.should have(4).items
      end
      it "returns an entries have date and count" do
        entry = artists_per_day.first
        entry.should have(2).entries
        last_created_date = Artist.active.all(:order => :created_at).last.created_at.to_date
        (Time.zone.at(entry[0].to_i).to_date - last_created_date).should be < 1.day
        entry[1].should be >= 1
      end
      it "does not include nil dates" do
        artists_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
    describe "compute_favorites_per_day" do
      before do
        u1 = fan
        u2 = artist
        u3 = artist2

        a1 = ArtPiece.first
        a1.update_attribute(:artist_id, artist.id)
        a2 = ArtPiece.last
        a2.update_attribute(:artist_id, artist.id)

        artist_stub = double(Artist,:id => 42, :emailsettings => {'favorites' => false})
        ArtPiece.any_instance.stub(:artist => artist_stub)
        u1.add_favorite a1
        u1.add_favorite artist
        u1.add_favorite u2
        u2.add_favorite a1
        u2.add_favorite artist
        u3.add_favorite a2

        @favorites_per_day = Admin::StatsController.new.send(:compute_favorites_per_day)
      end
      it "returns an array" do
        @favorites_per_day.should be_a_kind_of(Array)
        @favorites_per_day.should have(1).item
      end
      it "returns an entries have date and count" do
        entry = @favorites_per_day.first
        entry.should have(2).entries
        last_favorite_date = Favorite.all(:order => :created_at).last.created_at.utc.to_date
        Time.zone.at(entry[0].to_i).utc.to_date.should eql last_favorite_date
        entry[1].should >= 1
      end
      it "does not include nil dates" do
        @favorites_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
    describe "compute_art_pieces_per_day" do
      it "returns an array" do
        art_pieces_per_day.should be_a_kind_of(Array)
        art_pieces_per_day.should have_at_least(6).items
      end
      it "does not include nil dates" do
        art_pieces_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
  end

end
