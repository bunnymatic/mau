require 'rails_helper'

describe OpenStudiosParticipant do
  it 'validates youtube url looks like youtube if present' do
    subject.youtube_url = 'whatever'
    subject.valid?
    expect(subject.errors[:youtube_url]).not_to be_empty

    subject.youtube_url = 'https://www.youtube.com/watch?v=23ihawJKZcE'
    subject.valid?
    expect(subject.errors[:youtube_url]).to be_empty
  end

  describe 'fields' do
    describe 'video_conference_schedule' do
      let(:artist) { create(:artist) }
      let!(:open_studios_event) { create :open_studios_event, :with_special_event }
      let(:time_slots) { open_studios_event.special_event_time_slots }

      it 'allows storage of the video conference schedule' do
        schedule = time_slots.each_with_index.with_object({}) do |(slot, idx), memo|
          memo[slot] = idx.even?
        end
        subject.update({
                         user: artist,
                         open_studios_event:,
                         video_conference_schedule: schedule,
                       })
        subject.save!
        os_info = OpenStudiosParticipant.last
        expect(os_info.video_conference_schedule[time_slots[0]]).to eq true
        expect(os_info.video_conference_schedule[time_slots[1]]).to eq false
        expect(os_info.video_conference_schedule.size).to eq time_slots.size
      end
    end
  end
end
