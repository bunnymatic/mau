# frozen_string_literal: true

require 'rails_helper'

describe ApplicationEvent do
  it 'sends events to subscribers after save' do
    mock_messager = double(Messager)
    expect(mock_messager).to receive :publish
    expect(Messager).to receive(:new).and_return mock_messager
    OpenStudiosSignupEvent.create(message: 'this is a new open studios event')
  end

  describe '#scopes' do
    before do
      4.times.each do |x|
        FactoryBot.create(:generic_event, created_at: x.days.ago, data: { user: 'artist' })
      end
      FactoryBot.create(:open_studios_signup_event, created_at: 5.days.ago, data: { user: 'artist' })
    end

    describe 'by_recency' do
      it 'returns events in order by time' do
        expect(ApplicationEvent.by_recency.to_a).to eql ApplicationEvent.all.order(created_at: :desc).to_a
      end
    end

    describe 'since' do
      it 'returns only events that have happened since the input date' do
        events = ApplicationEvent.since(2.days.ago).to_a
        expect(events).to have(3).events
        expect(events.map(&:class).uniq).to eql [GenericEvent]
      end
    end
  end
end
