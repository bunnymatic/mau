# frozen_string_literal: true

require 'rails_helper'

describe UserNavigation do
  let(:artist) { create :artist }
  let(:artist_nav) { described_class.new(artist) }

  describe 'remind_for_open_studios_register?' do
    let(:artist_to_remind) { create(:artist) }
    let(:artist_to_remind_nav) { described_class.new(:artist_to_remind) }
    let(:future_open_studios_event) { FactoryBot.create(:open_studios_event, :future) }

    before do
      Timecop.freeze
      allow(OpenStudiosEventService).to receive(:current).and_return(future_open_studios_event)
      artist.open_studios_events << future_open_studios_event
    end

    after do
      Timecop.return
    end

    it 'returns true if artist has not registered for current event and it is no more than 12 weeks away' do
      expect(artist_to_remind_nav.remind_for_open_studios_register?).to eq(true)
    end

    it 'returns false if the artist is already registered for current event' do
      expect(artist_nav.remind_for_open_studios_register?).to eq(false)
    end
  end
end
