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
    freeze_time
    [past_oses, current_os, future_oses].flatten
  end

  describe '.current' do
    it 'returns the current os' do
      expect(service.current).to eq current_os
    end
  end

  describe '.for_display' do
    context 'when the event is in the db' do
      before do
        create(:open_studios_event, start_date: Date.new(2011, 4, 2))
      end
      it 'returns the pretty version for a given tag year first' do
        expect(service.for_display('201104')).to eql '2011 Apr'
      end
      it 'returns month first the date given month_first = true' do
        expect(service.for_display('201104', month_first: true)).to eql 'Apr 2-3 2011'
      end
    end
    context 'for a key that doesnt correspond to a known event' do
      it 'returns n/a' do
        expect(service.for_display('201104')).to eql 'n/a'
      end
    end
  end

  describe '.find_by_key' do
    before do
      allow(SafeCache).to receive(:read).and_return(nil, past_oses.last, past_oses.last)
      allow(SafeCache).to receive(:write).and_call_original
    end
    it 'finds and caches the event (by default)' do
      expect(service.find_by_key(past_oses.last.key)).to eq past_oses.last
      expect(SafeCache).to have_received(:write).once.with("os_event_#{past_oses.last.key}", past_oses.last)
    end
  end

  describe '.clear_cache' do
    before do
      allow(SafeCache).to receive(:delete)
    end

    it 'removes all the future, past and current caches' do
      service.clear_cache
      expect(SafeCache).to have_received(:delete).with(described_class::FUTURE_CACHE_KEY)
      expect(SafeCache).to have_received(:delete).with(described_class::PAST_CACHE_KEY)
      expect(SafeCache).to have_received(:delete).with(described_class::CURRENT_CACHE_KEY)
    end

    it 'removes the event cache based on key if it exists' do
      event = OpenStudiosEvent.new(id: 100, key: '12345')
      service.clear_cache(event)
      expect(SafeCache).to have_received(:delete).with('os_event_100')
      expect(SafeCache).to have_received(:delete).with('os_event_12345')

      expect(SafeCache).to have_received(:delete).with(described_class::FUTURE_CACHE_KEY)
      expect(SafeCache).to have_received(:delete).with(described_class::PAST_CACHE_KEY)
      expect(SafeCache).to have_received(:delete).with(described_class::CURRENT_CACHE_KEY)
    end
  end

  describe '#tally_os' do
    before do
      FactoryBot.create(:artist, :active, :with_studio, :with_art)
    end
    it 'tallies today\'s os participants' do
      expect { described_class.tally_os }.to change(OpenStudiosTally, :count).by(1)
    end
    it 'only records 1 entry per day' do
      expect do
        2.times { described_class.tally_os }
      end.to change(OpenStudiosTally, :count).by(1)
    end

    it 'updates the record if it runs more than once 1 entry per day' do
      described_class.tally_os
      a = Artist.all.reject(&:doing_open_studios?).first
      t = OpenStudiosTally.last
      a.open_studios_events << current_os
      described_class.tally_os
      expect(OpenStudiosTally.last.count).to eql(t.count + 1)
    end

    it 'does nothing if there are no open studios events' do
      OpenStudiosEvent.destroy_all
      expect { described_class.tally_os }.to change(OpenStudiosTally, :count).by(0)
    end
  end
end
