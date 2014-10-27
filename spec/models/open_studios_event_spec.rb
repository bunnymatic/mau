require 'spec_helper'

describe OpenStudiosEvent do
  
  let(:past_oses) {
    [
     FactoryGirl.create(:open_studios_event, :start_date => 6.months.ago),
     FactoryGirl.create(:open_studios_event, :start_date => 12.months.ago)
    ]
   }
  let(:current_os) { FactoryGirl.create(:open_studios_event, :start_date => 1.months.since) }
  let(:future_oses) { 
    [
     FactoryGirl.create(:open_studios_event, :start_date => 6.months.since),
     FactoryGirl.create(:open_studios_event, :start_date => 12.months.since)
    ]
  }

  before do
    Timecop.freeze
    [ past_oses, current_os, future_oses ].flatten
  end

  after do
    Timecop.return
  end

  describe '.pretty_print' do
    it "returns the pretty version for the current os" do
      expect(OpenStudiosEvent.pretty_print).to eql current_os.start_date.strftime("%Y %B")
    end
    it "returns the pretty version for a given tag" do
      expect(OpenStudiosEvent.pretty_print("201104")).to eql current_os.start_date.strftime("2011 Apr")
    end
  end

  describe '#pretty_print' do
    it "returns the pretty version for the current os" do
      expect(current_os.pretty_print).to eql current_os.start_date.strftime("%Y %B")
    end
  end

  describe '#future' do
    it 'includes 2 open studios' do
      expect(OpenStudiosEvent.future).to have(3).events
    end
  end

  describe '#past' do
    it 'includes 1 open studios' do
      expect(OpenStudiosEvent.past).to have(2).events
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
      expect(current_os.key).to eql current_os.start_date.year.to_s + ("%02d" % current_os.start_date.month)
    end
  end

end
