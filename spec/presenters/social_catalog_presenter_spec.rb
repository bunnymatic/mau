require 'rails_helper'

describe SocialCatalogPresenter do

  let(:open_studios_event) { FactoryGirl.create :open_studios_event }
  let!(:artists) do
    FactoryGirl.create_list(:artist, 3, :active, :with_links).map do |artist|
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
      expect(subject.send(:csv_headers)).to eql subject.send(:csv_keys).map { |k| k.to_s.humanize.capitalize }
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
    artist = expected_artists.first
    row = parsed.detect{|row| row['Full name'] == artist.full_name}
    expect(row).to be_present
    expect(row['Email']).to eql artist.email
    expect(row["Facebook"]).to eql artist.facebook.to_s
    expect(row["Twitter"]).to eql artist.twitter.to_s
  end

end
