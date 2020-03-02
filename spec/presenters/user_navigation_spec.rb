# frozen_string_literal: true

require 'rails_helper'

describe UserNavigation do
  let(:artist) { create :artist }
  let(:artist_nav) { described_class.new(artist) }

  describe 'remind_for_open_studios_register?' do
    let(:artist_to_remind) { create(:artist) }
    let(:artist_to_remind_nav) { described_class.new(:artist_to_remind) }

    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    context 'when there is a future open studios event' do
      let(:future_open_studios_event) { FactoryBot.create(:open_studios_event, :future) }

      before do
        Timecop.freeze
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

    context 'when there are no open studios events' do
      it 'returns false' do
        expect(artist_to_remind_nav.remind_for_open_studios_register?).to eq(false)
      end
    end

    context 'when there is no future open studios event' do
      before do
        create(:open_studios_event, start_date: 1.month.ago)
      end
      it 'returns false' do
        expect(artist_to_remind_nav.remind_for_open_studios_register?).to eq(false)
      end
    end
  end
end
