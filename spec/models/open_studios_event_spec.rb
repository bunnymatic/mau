# frozen_string_literal: true

require 'rails_helper'

describe OpenStudiosEvent do
  let(:past_oses) do
    [
      FactoryBot.create(:open_studios_event, start_date: 6.months.ago),
      FactoryBot.create(:open_studios_event, start_date: 12.months.ago)
    ]
  end
  let(:current_os) { FactoryBot.create(:open_studios_event, start_date: 1.month.since) }
  let(:future_oses) do
    [
      FactoryBot.create(:open_studios_event, start_date: 6.months.since),
      FactoryBot.create(:open_studios_event, start_date: 12.months.since)
    ]
  end

  before do
    # allow_any_instance_of(OpenStudiosEvent).to receive(:save_attached_files).and_return(true)
    Timecop.freeze
    [past_oses, current_os, future_oses].flatten
  end

  after do
    Timecop.return
  end

  describe '#for_display' do
    it 'returns the pretty version for the current os' do
      expect(current_os.for_display).to eql current_os.start_date.strftime('%Y %b')
    end
  end

  describe '#future' do
    it 'includes 2 open studios' do
      expect(OpenStudiosEvent.future.size).to eq(3)
    end
  end

  describe '#past' do
    it 'includes 1 open studios' do
      expect(OpenStudiosEvent.past.size).to eq(2)
    end
  end

  describe '#current' do
    it 'includes the nearest future event' do
      expect(OpenStudiosEvent.current).to eql current_os
    end

    it 'shows the first future event if today is monday after the last event' do
      Timecop.travel(current_os.end_date + 1.day)

      expect(OpenStudiosEvent.current).to eql future_oses.first
    end
  end

  describe '.key' do
    it 'returns a year month key based on start date' do
      expect(current_os.key).to eql current_os.start_date.year.to_s + sprintf('%02d', current_os.start_date.month)
    end
  end
end
