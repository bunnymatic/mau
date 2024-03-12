require 'rails_helper'
describe Admin::StatsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:artist) { FactoryBot.create(:artist, :active) }
  let(:artist2) { FactoryBot.create(:artist, :active) }
  before do
    login_as admin
  end

  describe 'json endpoints' do
    %i[art_pieces_count_histogram user_visits_per_day artists_per_day favorites_per_day art_pieces_per_day os_signups].each do |endpoint|
      describe endpoint.to_s do
        before do
          get endpoint, xhr: true
        end
        it_behaves_like 'successful json'
      end
    end
  end

  describe 'helper methods' do
    let(:art_pieces_per_day) { Admin::StatsController.new.send(:compute_art_pieces_per_day) }
    let(:artists_per_day) { Admin::StatsController.new.send(:compute_artists_per_day) }
    before do
      freeze_time
      FactoryBot.create(:artist, :active, :with_art, number_of_art_pieces: 2)
      3.times.each do |n|
        travel_to((1 + n).days.ago)
        FactoryBot.create(:artist, :active, :with_art, number_of_art_pieces: 2)
      end
    end

    describe '#compute_artists_per_day' do
      it 'returns an array' do
        expect(artists_per_day).to be_a_kind_of(Array)
        expect(artists_per_day.size).to eq(4)
      end
      it 'returns an entries have date and count' do
        entry = artists_per_day.first
        expect(entry.entries.size).to eq(2)
        last_created_date = Artist.active.order(:created_at).last.created_at.to_date
        expect(Time.zone.at(entry[0].to_i).to_date - last_created_date).to be < 1.day
        expect(entry[1]).to be >= 1
      end
      it 'does not include nil dates' do
        expect(artists_per_day.all? { |apd| !apd[0].nil? }).to be
      end
    end
    describe '#compute_favorites_per_day' do
      before do
        u1 = fan
        u2 = artist
        u3 = artist2

        a1 = ArtPiece.first
        a1.update!(artist:)
        a2 = ArtPiece.last
        a2.update!(artist:)

        artist_stub = double(Artist, id: 42, emailsettings: { 'favorites' => false })
        allow_any_instance_of(ArtPiece).to receive(:artist).and_return(artist_stub)
        create_favorite(u1, a1)
        create_favorite(u1, artist)
        create_favorite(u1, u2)

        create_favorite(u2, a1)
        create_favorite(u2, artist)

        create_favorite(u3, a2)

        @favorites_per_day = Admin::StatsController.new.send(:compute_favorites_per_day)
      end
      it 'returns an array' do
        expect(@favorites_per_day).to be_a_kind_of(Array)
        expect(@favorites_per_day.size).to eq(1)
      end
      it 'returns an entries have date and count' do
        entry = @favorites_per_day.first
        expect(entry.entries.size).to eq(2)
        last_favorite_date = Favorite.order(:created_at).last.created_at.utc.to_date
        expect(Time.zone.at(entry[0].to_i).utc.to_date).to eql last_favorite_date
        expect(entry[1]).to be >= 1
      end
      it 'does not include nil dates' do
        expect(@favorites_per_day.all? { |apd| !apd[0].nil? }).to be
      end
    end
  end
end
