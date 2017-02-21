require 'rails_helper'

describe SocialCatalogPresenter, type: :view do

  let(:open_studios_event) { FactoryGirl.create :open_studios_event }
  let(:studio) { create(:studio) }
  let(:unlisted_because_not_os) {
    create(:artist, :active, :with_links, :with_art)
  }
  let(:unlisted_because_no_art) {
    create(:artist, :active, :with_links, doing_open_studios: open_studios_event)
  }
  let(:listed_indy_artist) {
    create(:artist, :active, :with_art, :in_the_mission, doing_open_studios: open_studios_event)
  }
  let(:listed_studio_artist) {
    create(:artist, :active, :with_art, :with_links, doing_open_studios: open_studios_event, studio: studio)
  }
  let!(:artists) do
    [unlisted_because_no_art, unlisted_because_not_os, listed_indy_artist, listed_studio_artist]
  end
  let(:parsed) { CSV.parse(subject.csv, :headers => true) }

  before do
    # TODO: update studio/artist factories to set address properly without compute_geocode
    studio.update_attribute(:lat, 37.75)
    studio.update_attribute(:lng, -122.41)
    listed_indy_artist.artist_info.update_attribute(:lat, 37.76)
    listed_indy_artist.artist_info.update_attribute(:lng, -122.411)
  end

  describe '#artists' do
    it "returns artists who are doing os (and in the mission) and have art" do
      expect(subject.artists.map(&:model)).to match_array [listed_indy_artist, listed_studio_artist]
    end
    it "returns artist sorted by last name" do
      expect(subject.artists.map(&:lastname)).to be_monotonically_increasing
    end
  end

  describe '#csv_headers' do
    it "returns the capitalized humanized headers" do
      expected_headers = ["Studio", "Name", "Art URL", "Art Title", "Medium", "Tags", "MAU Link", "Email",
                          "Website", "Facebook", "Twitter", "Blog", "Pinterest",
                          "Myspace", "Flickr", "Instagram", "Artspan"]
      expect(subject.send(:csv_headers)).to eql expected_headers
    end
  end

  its(:csv_filename) { is_expected.to eql "mau_social_artists_#{open_studios_event.key}.csv" }

  it 'includes the right data in the csv' do
    expected_artists = [listed_indy_artist, listed_studio_artist]
    expect(parsed.size).to eq(expected_artists.count)
    expected_artists.each do |artist|
      row = parsed.detect{|row| row['Name'] == artist.full_name}
      expect(row).to be_present
      expect(row['Email']).to eql artist.email
      expect(row["Art URL"]).to eql artist.representative_piece.try(:photo).try(:url).to_s
      expect(row["Art Title"]).to eql artist.representative_piece.try(:title)
      expect(row["Tags"]).to eql artist.representative_piece.try(:tags).try(:join, ", ")
      expect(row["Facebook"]).to eql artist.facebook.to_s
      expect(row["Twitter"]).to eql artist.twitter.to_s
      expect(row["Studio"]).to eql artist.studio.try(:name).to_s
      expect(row["MAU Link"]).to eql artist_url(artist)
    end
  end

end
