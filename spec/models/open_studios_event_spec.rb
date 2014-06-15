require 'spec_helper'

describe OpenStudiosEvent do

  let(:past_os) { FactoryGirl.create(:open_studios_event, :start_date => 6.months.ago) }
  let(:current_os) { FactoryGirl.create(:open_studios_event, :start_date => 1.months.since) }
  let(:future_os) { FactoryGirl.create(:open_studios_event, :start_date => 6.months.since) }

  before do
    [past_os, current_os, future_os]
  end

  describe '#future' do
    it 'includes 2 open studios' do
      expect(OpenStudiosEvent.future).to have(2).events
    end
  end

  describe '#past' do
    it 'includes 1 open studios' do
      expect(OpenStudiosEvent.past).to have(1).events
    end
  end

  describe '#current' do
    it 'includes the nearest future event' do
      expect(OpenStudiosEvent.current).to eql current_os
    end
  end

  describe '.key' do
    it 'returns a year month key based on start date' do
      expect(current_os.key).to eql current_os.start_date.year.to_s + ("%02d" % current_os.start_date.month)
    end
  end

end
