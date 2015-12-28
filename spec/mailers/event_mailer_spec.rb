require 'spec_helper'

describe EventMailer do
  let(:user) { FactoryGirl.create(:artist, :active)}
  let!(:event) { FactoryGirl.create(:event, :user => user) }

  before do
    list = FactoryGirl.create(:event_email_list, :with_member)
  end

  it 'delivers to the right folks' do
    m = EventMailer.event_added(Event.first)
    EventMailerList.first.emails.each do |expected|
      expect(m.to).to include expected.email
    end
    expect(m.from).to include 'info@missionartistsunited.org'
  end
end
