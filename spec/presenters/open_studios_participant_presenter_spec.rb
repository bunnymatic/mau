require 'rails_helper'

describe OpenStudiosParticipantPresenter do
  let(:participant) { create(:open_studios_participant) }
  subject(:presenter) { described_class.new(participant) }

  before do
    freeze_time
    travel_to Time.zone.local(2021, 4, 1)
  end

  it 'delegates a bunch of stuff' do
    %i[youtube_url shop_url].each do |f|
      expect(presenter.send(f)).to eq participant.send(f)
    end
  end

  context 'when a participant is doing everything' do
    let(:user) do
      create(:user, phone: '4155559999')
    end
    let(:participant) do
      create(:open_studios_participant,
             :with_conference_schedule,
             user:,
             show_email: true,
             show_phone_number: true)
    end

    its(:show_phone?) { is_expected.to eq true }
    its(:has_shop?) { is_expected.to eq true }
    its(:has_youtube?) { is_expected.to eq true }
    its(:has_scheduled_conference?) { is_expected.to eq true }
    it 'time slots are formatted' do
      expect(subject.conference_time_slots).to include 'Apr 1 12-4pm PDT'
      expect(subject.conference_time_slots).to include 'Apr 2 12-4pm PDT'
    end
  end

  context 'when a participant is doing nothing' do
    let(:participant) do
      create(:open_studios_participant,
             shop_url: nil,
             youtube_url: nil,
             video_conference_url: nil,
             show_email: false,
             show_phone_number: false)
    end

    its(:show_phone?) { is_expected.to eq false }
    its(:has_shop?) { is_expected.to eq false }
    its(:has_youtube?) { is_expected.to eq false }
    its(:has_scheduled_conference?) { is_expected.to eq false }
  end

  describe '.broadcasting?' do
    let(:participant) do
      create(:open_studios_participant,
             :with_conference_schedule)
    end

    it "is true if we're in a scheduled conference time" do
      # get first time slot
      time_slot = OpenStudiosParticipant.parse_time_slot(presenter.send(:time_slots).first)
      travel_to(time_slot.first + 20.minutes)
      expect(presenter.broadcasting?).to eq true
    end
    it "is false if it's before a scheduled conference time" do
      # get first time slot
      time_slot = OpenStudiosParticipant.parse_time_slot(presenter.send(:time_slots).first)
      travel_to(time_slot.first - 20.minutes)
      expect(presenter.broadcasting?).to eq false
    end
    it "is false if it's after a scheduled conference time" do
      # get first time slot
      time_slot = OpenStudiosParticipant.parse_time_slot(presenter.send(:time_slots).last)
      travel_to(time_slot.last + 2.minutes)
      expect(presenter.broadcasting?).to eq false
    end
  end
end
