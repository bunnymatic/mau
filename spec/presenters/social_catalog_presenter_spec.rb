# frozen_string_literal: true

require 'rails_helper'

describe SocialCatalogPresenter do
  include PresenterSpecHelpers
  def gen_links
    {
      facebook: Faker::Internet.url,
      website: Faker::Internet.url,
      twitter: Faker::Internet.url,
      instagram: Faker::Internet.url,
    }
  end

  def fake_art(opts = {})
    instance_double(ArtPiece, opts.merge(
                                persisted?: true,
                                title: 'title',
                                photo: 'the-image.jpg',
                                medium: nil,
                                tags: [],
                                uniq_tags: [],
                                updated_at: rand.days.ago,
                              ))
  end

  let!(:open_studios_event) { FactoryBot.create :open_studios_event }
  let(:studio) { build_stubbed(:studio) }
  let(:listed_indy_artist) do
    name = Faker::Name.name
    art_pieces = [fake_art]
    attrs = attributes_for(:artist).merge(gen_links).merge(
      artist?: true,
      art_pieces: art_pieces,
      artist_info: build_stubbed(:artist_info),
      doing_open_studios?: true,
      full_name: name,
      get_name: name,
      in_the_mission?: true,
      is_a?: true,
      max_pieces: 4,
      representative_piece: art_pieces.first,
      sortable_name: 'joe',
      studio: nil,
    )
    User.stored_attributes[:links].each do |attr|
      attrs[attr] = nil
    end
    instance_double(Artist, **attrs)
  end
  let(:listed_studio_artists) do
    Array.new(5).map do
      name = Faker::Name.name
      art_pieces = [fake_art]
      attrs = attributes_for(:artist).merge(gen_links).merge(
        artist?: true,
        art_pieces: [instance_double(ArtPiece, persisted?: true)],
        artist_info: build_stubbed(:artist_info, max_pieces: 4),
        doing_open_studios?: true,
        full_name: name,
        get_name: name,
        in_the_mission?: true,
        is_a?: true,
        max_pieces: 4,
        representative_piece: art_pieces.first,
        sortable_name: 'joe',
        studio: studio,
      )
      User.stored_attributes[:links].each do |attr|
        attrs[attr] = nil
      end
      instance_double(Artist, **attrs)
    end
  end

  let!(:artists) do
    [listed_indy_artist] + listed_studio_artists
  end
  let(:parsed) { CSV.parse(subject.csv, headers: true) }

  before do
    mock_os = instance_double(OpenStudiosEvent, key: open_studios_event.key)
    allow(mock_os).to receive_message_chain(:artists, :in_the_mission).and_return(artists)
    allow(OpenStudiosEventService).to receive(:current).and_return(mock_os)
  end

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
      expected_headers = ['Studio', 'Name', 'Art URL', 'Art Title', 'Medium', 'Tags', 'MAU Link', 'Email',
                          'Website', 'Facebook', 'Twitter', 'Blog', 'Pinterest',
                          'Myspace', 'Flickr', 'Instagram', 'Artspan']
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
      expect(row['Art URL']).to eql artist.representative_piece.try(:photo).try(:url).to_s
      expect(row['Art Title']).to eql artist.representative_piece.try(:title)
      expect(row['Tags']).to eql artist.representative_piece.try(:tags).try(:join, ', ')
      expect(row['Facebook']).to eql artist.facebook.to_s
      expect(row['Twitter']).to eql artist.twitter.to_s
      expect(row['Studio']).to eql artist.studio.try(:name).to_s
      expect(row['MAU Link']).to eql artist_url(artist)
    end
  end
end
