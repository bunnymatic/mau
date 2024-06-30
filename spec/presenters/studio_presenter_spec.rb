require 'rails_helper'

describe StudioPresenter do
  let(:studio) { FactoryBot.create(:studio, cross_street: 'hollywood', phone: '4156171234') }
  let(:artist1) { FactoryBot.create(:artist, :active, :with_art, studio:) }
  let(:artist2) { FactoryBot.create(:artist, :active, studio:) }
  let(:artist3) { FactoryBot.create(:artist, :pending, studio:) }
  let!(:artists) { [artist1, artist2, artist3] }
  subject(:presenter) { StudioPresenter.new(studio) }

  its(:artists_with_art?) { is_expected.to be_truthy }
  its(:artists_without_art?) { is_expected.to be_truthy }
  its(:artists_with_art) { is_expected.to have(1).item }
  its(:artists_without_art) { is_expected.to have(1).item }
  its(:name) { is_expected.to eql studio.name }
  its(:page_title) { is_expected.to eql "Mission Artists - Studio: #{studio.name}" }
  its(:street_with_cross) { is_expected.to eql "#{studio.street} (@ hollywood)" }
  its(:indy?) { is_expected.to be_falsy }
  its(:image) { is_expected.to match %r{rails/active_storage} }

  it '.artists returns the active artists' do
    expect(presenter.artists).to eq studio.artists.active
  end

  describe 'formatted_phone' do
    it 'returns nicely formatted phone #' do
      expect(presenter.formatted_phone).to eql '(415) 617-1234'
    end
  end

  describe '.artists_count_label' do
    context 'when there are no artists' do
      let(:artists) { [] }
      let(:studio) { create(:studio) }
      it 'returns an empty string' do
        expect(presenter.artists_count_label).to eq ''
      end
    end

    context 'when there is 1 artist' do
      let(:artists) { [] }
      let(:studio) { artist.studio }
      let(:artist) { create(:artist, :with_studio) }
      it 'returns a label singularized' do
        expect(presenter.artists_count_label).to eq '1 artist'
      end
    end

    context 'when there is more than 1 artist' do
      it 'returns a label with artist count info' do
        expect(presenter.artists_count_label).to eq '2 artists'
      end
    end
  end

  describe 'open_studios_artists' do
    let(:all_os_artists) do
      [
        create(:artist, doing_open_studios: true),
        create(:artist, studio:, doing_open_studios: true),
      ]
    end
    before do
      create(:open_studios_event, :future, title: 'Custom Open Studios')
      all_os_artists
    end
    it 'returns all open studios artists in this studio' do
      expect(Artist.count).to eq 5
      expect(presenter.artists.count).to eq 2
      expect(presenter.open_studios_artists).to eq [all_os_artists[1]]
    end

    describe '.open_studios_artists_count_label' do
      it 'returns a label with os artist count info' do
        expect(presenter.open_studios_artists_count_label).to eq '1 artist in Custom Open Studios'
      end
    end
  end
end
