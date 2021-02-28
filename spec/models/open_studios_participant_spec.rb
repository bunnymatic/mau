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
end
