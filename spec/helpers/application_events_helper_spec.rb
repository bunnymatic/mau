require 'rails_helper'

describe ApplicationEventsHelper do
  describe 'link_to_user' do
    let(:artist) { FactoryBot.create :artist, :active }
    let(:no_user_event) { FactoryBot.create :generic_event, message: 'blop', data: { 'user' => nil } }
    let(:event) { FactoryBot.create :open_studios_signup_event, message: 'blop', data: { 'user' => artist.login, 'user_id' => artist.id } }

    it { expect(helper.link_to_event_user(no_user_event)).to eql '' }
    it 'links to the artist' do
      link_text = helper.link_to_event_user(event)
      expect(link_text).to eql(link_to(artist.login, artist_path(artist.id)))
    end
  end
end
