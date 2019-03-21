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
    it 'uses a db version of it\'s available' do
      expect(service.for_display(future_oses.last.key)).to eql sprintf('%s %s', (Time.zone.now + 1.year).year, Time.zone.now.strftime('%b'))
    end
  end

  describe '.date' do
    it 'returns the date for a key that is not tied to os in the db' do
      expect(service.date('201104')).to eql Time.zone.parse('Apr 2011')
    end
    it 'returns the start date for a key that matches one in the db' do
      expect(service.date(OpenStudiosEvent.first.key)).to eql OpenStudiosEvent.first.start_date
    end
  end

  describe '.parse_key' do
    it 'returns the year month as a string' do
      expect(service.parse_key('201410')).to eql '2014 Oct'
    end
    it 'returns the month and year as a string with reverse' do
      expect(service.parse_key('201410', true)).to eql 'Oct 2014'
    end
  end
end
