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

  its(:event_website_url) { should eql event_website }

  it{ should_not be_published }
  its(:event_classes) { should include 'past' }
  its(:event_classes) { should include 'unpublished' }
  its(:title) { should eql event.title }

  its(:display_event_time) { should match starttime.strftime("%a %b %e") }
  its(:display_event_time) { should match endtime.strftime("- %a %b") }

  its(:display_reception_time) { should match reception_starttime.strftime("%a %b %e") }
  its(:display_reception_time) { should match reception_endtime.strftime(" %l:%M%p") }

  context 'when the website address does not start http' do
    let(:event_website) { 'www.twitter.com' }
    its(:event_website_url) { should eql 'http://' + event_website }
  end

  context 'when the website address starts https' do
    let(:event_website) { 'https://ssl.whatever.com/this/that' }
    its(:event_website_url) { should eql event_website  }
  end

  context 'when end time is the same day as start time' do
    let(:endtime) { starttime + 1.minute }
    its(:display_event_time) { should match starttime.strftime("%a %b %e") }
    its(:display_event_time) { should_not match starttime.strftime("- %a %b") }
  end

  context 'when the event is in progress' do
    let(:starttime) { Time.zone.now - 1.day }
    its(:event_classes) { should include 'in_progress' }
  end

  context 'when the event is in the future' do
    let(:starttime) { Time.zone.now + 1.day }
    its(:event_classes) { should include 'future' }
  end

  context 'when the event is published' do
    let(:published_at) { Time.zone.now }
    it{ should be_published }
  end

end
