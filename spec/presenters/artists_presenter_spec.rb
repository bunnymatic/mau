# frozen_string_literal: true
require 'rails_helper'

describe ArtistsPresenter do
  include PresenterSpecHelpers

  let(:os_only) { false }
  let(:artists) { FactoryGirl.create_list :artist, 4, :with_art, :in_the_mission }

  subject(:presenter) { ArtistsPresenter.new(os_only) }

  before do
    # bypass test geocoder by saving without validations
    artists.each do |a|
      a.artist_info.attributes = { lat: 37.75, lng: -122.41 }
      a.artist_info.save validate: false
    end
  end
  describe '#artists' do
    context 'os_only is false' do
      it 'shows active artists sorted by name' do
        expect(subject.artists.map(&:artist)).to eql Artist.active.sort_by(&:sortable_name).to_a
      end
    end

    context 'os_only is true' do
      let(:os_only) { true }
      let(:os_participants) { Artist.active.open_studios_participants }
      it 'shows only os artists' do
        expected = os_participants.reject { |a| !a.in_the_mission? }.sort_by(&:sortable_name).to_a
        expect(subject.artists.map(&:artist).to_a).to eql(expected)
      end
    end
  end

  describe '#artists_only_in_the_mission' do
    context 'os_only is false' do
      it 'shows active artists who live in the mission sorted by name' do
        expected_results = subject.artists_only_in_the_mission.map(&:artist)
        actual_results = Artist.active.select(&:in_the_mission?).sort_by(&:sortable_name)
        expect(actual_results).to eql(expected_results)
      end
      it 'returns artist presenter objects' do
        expect(subject.artists_only_in_the_mission.first).to be_a_kind_of ArtistPresenter
      end
    end

    context 'os_only is true' do
    end
  end
end
