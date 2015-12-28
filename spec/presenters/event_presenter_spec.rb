require 'spec_helper'

describe EventPresenter do

  include PresenterSpecHelpers

  let(:published_at) { nil }
  let(:starttime) { Time.zone.now - 10.days }
  let(:endtime) { starttime + 2.days }
  let(:reception_starttime) { starttime + 1.day }
  let(:reception_endtime) { reception_starttime + 2.hours }
  let(:event_website) { 'http://my.event.com' }
  let(:event) { FactoryGirl.create(:event, :url => event_website, :published_at => published_at,
                                   :starttime => starttime, :endtime => endtime,
                                   :reception_starttime => reception_starttime, :reception_endtime => reception_endtime
                                   ) }
  subject(:presenter) { EventPresenter.new(mock_view_context, event) }

  describe '#event_website_url' do
    subject { super().event_website_url }
    it { should eql event_website }
  end

  it{ should_not be_published }

  describe '#event_classes' do
    subject { super().event_classes }
    it { should include 'past' }
  end

  describe '#event_classes' do
    subject { super().event_classes }
    it { should include 'unpublished' }
  end

  describe '#title' do
    subject { super().title }
    it { should eql event.title }
  end

  describe '#display_event_time' do
    subject { super().display_event_time }
    it { should match starttime.strftime("%a %b %e") }
  end

  describe '#display_event_time' do
    subject { super().display_event_time }
    it { should match endtime.strftime("- %a %b") }
  end

  describe '#display_reception_time' do
    subject { super().display_reception_time }
    it { should match reception_starttime.strftime("%a %b %e") }
  end

  describe '#display_reception_time' do
    subject { super().display_reception_time }
    it { should match reception_endtime.strftime(" %l:%M%p") }
  end

  context 'when the website address does not start http' do
    let(:event_website) { 'www.twitter.com' }

    describe '#event_website_url' do
      subject { super().event_website_url }
      it { should eql 'http://' + event_website }
    end
  end

  context 'when the website address starts https' do
    let(:event_website) { 'https://ssl.whatever.com/this/that' }

    describe '#event_website_url' do
      subject { super().event_website_url }
      it { should eql event_website  }
    end
  end

  context 'when end time is the same day as start time' do
    let(:endtime) { starttime + 1.minute }

    describe '#display_event_time' do
      subject { super().display_event_time }
      it { should match starttime.strftime("%a %b %e") }
    end

    describe '#display_event_time' do
      subject { super().display_event_time }
      it { should_not match starttime.strftime("- %a %b") }
    end
  end

  context 'when the event is in progress' do
    let(:starttime) { Time.zone.now - 1.day }

    describe '#event_classes' do
      subject { super().event_classes }
      it { should include 'in_progress' }
    end
  end

  context 'when the event is in the future' do
    let(:starttime) { Time.zone.now + 1.day }

    describe '#event_classes' do
      subject { super().event_classes }
      it { should include 'future' }
    end
  end

  context 'when the event is published' do
    let(:published_at) { Time.zone.now }
    it{ should be_published }
  end

end
