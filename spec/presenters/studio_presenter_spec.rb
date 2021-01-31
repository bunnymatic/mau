# frozen_string_literal: true

require 'rails_helper'

describe StudioPresenter do
  let(:studio) { FactoryBot.create(:studio, cross_street: 'hollywood', phone: '4156171234') }
  let!(:artist1) { FactoryBot.create(:artist, :active, :with_art, studio: studio) }
  let!(:artist2) { FactoryBot.create(:artist, :active, studio: studio) }
  let!(:artist3) { FactoryBot.create(:artist, :pending, studio: studio) }
  subject(:presenter) { StudioPresenter.new(studio) }

  its(:artists_with_art?) { is_expected.to be_truthy }
  its(:artists_without_art?) { is_expected.to be_truthy }
  its(:artists_with_art) { is_expected.to have(1).item }
  its(:artists_without_art) { is_expected.to have(1).item }
  its(:name) { is_expected.to eql studio.name }
  its(:page_title) { is_expected.to eql "Mission Artists - Studio: #{studio.name}" }
  its(:street_with_cross) { is_expected.to eql "#{studio.street} (@ hollywood)" }
  its(:indy?) { is_expected.to be_falsy }
  its(:image) { is_expected.to match %r{studios/photos/.*/small/new-studio.jpg} }

  it '.artists returns the active artists' do
    expect(presenter.artists).to eq studio.artists.active
  end

  describe 'formatted_phone' do
    it 'returns nicely formatted phone #' do
      expect(presenter.formatted_phone).to eql '(415) 617-1234'
    end
  end

  describe 'open_studios_artists' do
    let(:all_os_artists) do
      [
        create(:artist, doing_open_studios: true),
        create(:artist, studio: studio, doing_open_studios: true),
      ]
    end
    before do
      create(:open_studios_event, :future)
      all_os_artists
    end
    it 'returns all open studios artists in this studio' do
      expect(Artist.count).to eq 5
      expect(presenter.artists.count).to eq 2
      expect(presenter.open_studios_artists).to eq [all_os_artists[1]]
    end
  end
end
