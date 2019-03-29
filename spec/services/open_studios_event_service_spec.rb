# frozen_string_literal: true

require 'rails_helper'
describe OpenStudiosEventService do
  let(:past_oses) do
    [
      FactoryBot.create(:open_studios_event, start_date: 6.months.ago),
      FactoryBot.create(:open_studios_event, start_date: 12.months.ago),
    ]
  end
  let(:current_os) { FactoryBot.create(:open_studios_event, start_date: 1.month.since) }
  let(:future_oses) do
    [
      FactoryBot.create(:open_studios_event, start_date: 6.months.since),
      FactoryBot.create(:open_studios_event, start_date: 12.months.since),
    ]
  end

  subject(:service) { described_class }

  before do
    # allow_any_instance_of(OpenStudiosEvent).to receive(:save_attached_files).and_return(true)
    Timecop.freeze
    [past_oses, current_os, future_oses].flatten
  end

  after do
    Timecop.return
  end

  describe '.for_display' do
    it 'returns the pretty version for a given tag' do
      expect(service.for_display('201104')).to eql '2011 Apr'
    end
    it 'reverses the date given reverse = true' do
      expect(service.for_display('201104', true)).to eql 'Apr 2011'
    end
  end

  describe '.date' do
    it 'returns the date for a key whether or not there is an event in the db' do
      expect(service.date('201104')).to eql Time.zone.parse('Apr 2011')
      expect(service.date(OpenStudiosEvent.first.key)).to eql OpenStudiosEvent.first.start_date
    end
  end

  describe '.parse_key' do
    it 'returns the year month as a string and can return it reversed' do
      expect(service.parse_key('201410')).to eql '2014 Oct'
      expect(service.parse_key('201410', true)).to eql 'Oct 2014'
    end
  end

  describe '.find' do
    before do
      allow(SafeCache).to receive(:read).and_return(nil, past_oses.last, past_oses.last)
      allow(SafeCache).to receive(:write).and_call_original
    end
    it 'finds and caches the event (by default)' do
      expect(service.find(past_oses.last.id)).to eq past_oses.last
      service.find(past_oses.last.id)
      service.find(past_oses.last.id)
      expect(SafeCache).to have_received(:read).exactly(3).times
      expect(SafeCache).to have_received(:write).once
    end
  end

  describe '.find_by' do
    before do
      allow(SafeCache).to receive(:read).and_return(nil, past_oses.last, past_oses.last)
      allow(SafeCache).to receive(:write).and_call_original
    end
    it 'finds and caches the event (by default)' do
      expect(service.find_by(key: past_oses.last.key)).to eq past_oses.last
      expect(SafeCache).to have_received(:write).once.with("os_event_#{past_oses.last.id}", past_oses.last)
    end
  end
end
