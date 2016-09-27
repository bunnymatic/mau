require 'rails_helper'

describe SocialCatalogPresenter, type: :view do

  let(:open_studios_event) { FactoryGirl.create :open_studios_event }
  let(:studio) { create(:studio) }
  let!(:artists) do
    FactoryGirl.create_list(:artist, 2, :active, :with_links).map do |artist|
      artist.update_os_participation open_studios_event.key, true
      artist
    end
    FactoryGirl.create_list(:artist, 2, :active, :with_art, :with_links, studio: studio).map do |artist|
      artist.update_os_participation open_studios_event.key, true
      artist
    end
  end
  let(:social_keys) { SocialCatalogPresenter::SOCIAL_KEYS }
  let(:parsed) { CSV.parse(subject.csv, :headers => true) }

  describe '#artists' do
    it "as an array is sorted by last name" do
      expected_result = (Artist.active.open_studios_participants.select{|a|
                           social_keys.map{|s| a.send(s).present?}.any?
                         }).sort(&Artist::SORT_BY_LASTNAME)
      expect(subject.artists.to_a).to eql expected_result
    end
  end

  describe '#csv_headers' do
    it "returns the capitalized humanized headers" do
      expected_headers = subject.send(:csv_keys).map { |k| k.to_s.humanize.capitalize } +
                         [ "Art Piece", "Studio Affiliation", "MAU Link" ]
      expect(subject.send(:csv_headers)).to eql expected_headers
    end
  end

  describe '#csv_filename' do
    subject { super().csv_filename }
    it { should eql "mau_social_artists_#{open_studios_event.key}.csv" }
  end
  it 'includes the right data in the csv' do
    expected_artists = Artist.active.open_studios_participants.select do |a|
      social_keys.map{|s| a.send(s).present?}.any?
    end
    expect(parsed.size).to eq(expected_artists.count)
    expected_artists.each do |artist|
      row = parsed.detect{|row| row['Full name'] == artist.full_name}
      puts "Testing row #{artist.full_name}\n#{row.inspect}"
      expect(row).to be_present
      expect(row['Email']).to eql artist.email
      expect(row["Facebook"]).to eql artist.facebook.to_s
      expect(row["Twitter"]).to eql artist.twitter.to_s
      expect(row["Studio Affiliation"]).to eql artist.studio.try(:name).to_s
      expect(row["Art Piece"]).to eql artist.representative_piece.try(:photo).try(:url).to_s
      expect(row["MAU Link"]).to eql artist_url(artist)
    end
  end

end
