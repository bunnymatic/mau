require 'rails_helper'

describe SocialCatalogPresenter do
  include PresenterSpecHelpers

  let(:studio) { create(:studio) }

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
        'Instagram',
        'Artspan',
      ]
      expect(subject.send(:csv_headers)).to eql expected_headers
    end
  end

  context 'when there is no current open studios' do
    describe '#artists' do
      it 'returns an empty array' do
        expect(subject.artists).to eq []
      end
      its(:csv_filename) { is_expected.to eql 'mau_social_artists.csv' }
    end

    describe '.csv' do
      let(:parsed_csv) { CSV.parse(subject.csv, headers: true) }
      it 'returns nothing' do
        expect(parsed_csv.length).to eq 0
      end
    end
  end

  context 'when there is an active open studios' do
    let!(:open_studios_event) { FactoryBot.create :open_studios_event }

    context 'when there are no artists participating' do
      describe '#artists' do
        it 'returns an empty array' do
          expect(subject.artists).to eq []
        end
        its(:csv_filename) { is_expected.to eql "mau_social_artists_#{open_studios_event.key}.csv" }
      end

      describe '.csv' do
        let(:parsed_csv) { CSV.parse(subject.csv, headers: true) }
        it 'returns nothing' do
          expect(parsed_csv.length).to eq 0
        end
      end
    end
    context 'when there are artists participating' do
      let(:listed_indy_artist) do
        create(:artist, :active, :in_the_mission, :with_links, :with_art, { doing_open_studios: true })
      end
      let(:listed_studio_artists) do
        create_list(:artist, 5, :active, :in_the_mission, :with_links, :with_art, doing_open_studios: true, studio:)
      end

      let!(:artists) do
        [listed_indy_artist] + listed_studio_artists
      end

      describe '#artists' do
        it 'returns artists who are doing os (and in the mission) and have art' do
          expect(subject.artists.map(&:model)).to match_array [listed_indy_artist] + listed_studio_artists
        end
        it 'returns artist sorted by art piece updated at within a studio' do
          expect(subject.artists.map { |a| a.representative_piece.updated_at }).to be_monotonically_decreasing
        end
      end

      its(:csv_filename) { is_expected.to eql "mau_social_artists_#{open_studios_event.key}.csv" }

      describe '.csv' do
        let(:parsed_csv) { CSV.parse(subject.csv, headers: true) }
        it 'includes the right data in the csv' do
          expected_artists = [listed_indy_artist] + listed_studio_artists
          expect(parsed_csv.size).to eq(expected_artists.count)
          expected_artists.each do |artist|
            row = parsed_csv.detect { |r| r['Name'] == artist.full_name }
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
    end
  end
end
