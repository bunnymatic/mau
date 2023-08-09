require 'rails_helper'

describe SocialCatalogPresenter do
  include PresenterSpecHelpers

  let!(:open_studios_event) { FactoryBot.create :open_studios_event }
  let(:studio) { create(:studio) }
  let(:listed_indy_artist) do
    create(:artist, :active, :in_the_mission, :with_links, :with_art, { doing_open_studios: true })
  end
  let(:listed_studio_artists) do
    create_list(:artist, 5, :active, :in_the_mission, :with_links, :with_art, doing_open_studios: true, studio:)
  end

  let!(:artists) do
    [listed_indy_artist] + listed_studio_artists
  end
  let(:parsed) { CSV.parse(subject.csv, headers: true) }

  describe '#artists' do
    it 'returns artists who are doing os (and in the mission) and have art' do
      expect(subject.artists.map(&:model)).to match_array [listed_indy_artist] + listed_studio_artists
    end
    it 'returns artist sorted by art piece updated at within a studio' do
      expect(subject.artists.map { |a| a.representative_piece.updated_at }).to be_monotonically_decreasing
    end
  end

  describe '#csv_headers' do
    it 'returns the capitalized humanized headers' do
      expected_headers = [
        'Studio',
        'Name',
        'Art URL',
        'Art Title',
        'Medium',
        'Tags',
        'MAU Link',
        'Email',
        'Website',
        'Facebook',
        'Twitter',
        'Blog',
        'Pinterest',
        'Myspace',
        'Flickr',
        'Instagram',
        'Artspan',
      ]
      expect(subject.send(:csv_headers)).to eql expected_headers
    end
  end

  its(:csv_filename) { is_expected.to eql "mau_social_artists_#{open_studios_event.key}.csv" }

  it 'includes the right data in the csv' do
    expected_artists = [listed_indy_artist] + listed_studio_artists
    expect(parsed.size).to eq(expected_artists.count)
    expected_artists.each do |artist|
      row = parsed.detect { |r| r['Name'] == artist.full_name }
      expect(row).to be_present
      expect(row['Email']).to eql artist.email
      expect(row['Art URL']).to eql artist.representative_piece.image(:original)
      expect(row['Art Title']).to eql artist.representative_piece.try(:title)
      expect(row['Tags']).to eql artist.representative_piece.try(:tags).try(:join, ', ')
      expect(row['Facebook']).to eql artist.facebook.to_s
      expect(row['Twitter']).to eql artist.twitter.to_s
      expect(row['Studio']).to eql artist.studio.try(:name).to_s
      expect(row['MAU Link']).to eql artist_url(artist)
    end
  end
end
