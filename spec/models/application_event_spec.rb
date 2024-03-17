require 'rails_helper'

describe ApplicationEvent do
  describe '#scopes' do
    before do
      FactoryBot.create(:open_studios_signup_event, created_at: 5.days.ago, data: { user: 'artist' })
      4.times.each do |x|
        FactoryBot.create(:generic_event, created_at: x.days.ago, data: { user: 'artist' })
      end
    end

    describe '.by_recency' do
      it 'returns events in order by time' do
        expect(described_class.by_recency.to_a).to eql described_class.order(created_at: :desc).to_a
      end
    end

    describe '.since' do
      it 'returns only events that have happened since the input date' do
        events = described_class.since(49.hours.ago).to_a
        expect(events).to have(3).events
        expect(events.map(&:class).uniq).to eql [GenericEvent]
      end
    end

    describe '.available_types' do
      it 'returns array of types that are represented in the db sorted by name' do
        expect(described_class.available_types).to eq %w[GenericEvent OpenStudiosSignupEvent]
      end
    end
  end
end
