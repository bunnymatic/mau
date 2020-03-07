# frozen_string_literal: true

require 'rails_helper'

describe UserNavigation do
  describe 'remind_for_open_studios_register?' do
    let(:artist) { create(:artist) }
    subject(:navigation) { described_class.new(artist) }

    context 'when open studios is less than 12 weeks away' do
      before do
        @os = create(:open_studios_event, start_date: 10.weeks.since)
      end
      it 'returns true' do
        expect(navigation.remind_for_open_studios_register?).to eq true
      end

      context 'if the user is already signed up' do
        before do
          artist.open_studios_events << @os
        end
        it 'returns false' do
          expect(navigation.remind_for_open_studios_register?).to eq false
        end
      end

      context 'when the user is not logged in' do
        let(:artist) { nil }
        it 'returns false' do
          expect(navigation.remind_for_open_studios_register?).to eq false
        end
      end

      context 'when the user is logged in as a fan' do
        let(:artist) { create(:fan) }
        it 'returns false' do
          expect(navigation.remind_for_open_studios_register?).to eq false
        end
      end
    end

    context 'when open studios is more than 12 weeks away' do
      before do
        @os = create(:open_studios_event, start_date: 13.weeks.since)
      end
      it 'returns false' do
        expect(navigation.remind_for_open_studios_register?).to eq false
      end
    end

    context 'when open studios are only in the past' do
      before do
        create(:open_studios_event, start_date: 1.month.ago)
      end
      it 'returns false' do
        expect(navigation.remind_for_open_studios_register?).to eq(false)
      end
    end

    context 'when there are no open studios events' do
      it 'returns false' do
        expect(navigation.remind_for_open_studios_register?).to eq(false)
      end
    end
  end
end
