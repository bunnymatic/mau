require 'spec_helper'
describe OpenStudiosEventService do

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
    OpenStudiosEvent.any_instance.stub(:save_attached_files).and_return(true)
    Timecop.freeze
    [ past_oses, current_os, future_oses ].flatten
  end

  after do
    Timecop.return
  end

  describe '.for_display' do
    it "returns the pretty version for a given tag" do
      expect(OpenStudiosEventService.for_display("201104")).to eql current_os.start_date.strftime("2011 Apr")
    end
    it "reverses the date given reverse = true" do
      expect(OpenStudiosEventService.for_display("201104", true)).to eql current_os.start_date.strftime("Apr 2011")
    end
  end

end
