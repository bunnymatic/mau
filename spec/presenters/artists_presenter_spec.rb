# frozen_string_literal: true

require 'rails_helper'

describe ArtistsPresenter do
  include PresenterSpecHelpers

  let(:os_only) { false }
  let(:artists) { FactoryBot.create_list :artist, 4, :with_art, :in_the_mission }

  subject(:presenter) { ArtistsPresenter.new(os_only) }

  describe '#artists' do
    context 'os_only is false' do
      it 'shows active artists sorted by name' do
        expect(subject.artists.map(&:artist)).to eql Artist.active.sort_by(&:sortable_name).to_a
      end
    end

    context 'os_only is true' do
      let(:os_only) { true }
      let(:os_participants) { OpenStudiosParticipant.all.map(&:user) }
      before do
        artists.first.open_studios_events << create(:open_studios_event)
      end
      it 'shows only os artists' do
        expected = os_participants.select(&:in_the_mission?).sort_by(&:sortable_name).to_a
        expect(subject.artists.map(&:artist).to_a).to eql(expected)
      end
    end
  end
end
