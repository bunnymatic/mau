require 'spec_helper'

describe ApplicationEventsHelper do
  describe 'link_to_user', eventmachine: true do
    let(:artist) { FactoryGirl.create :artist, :active }
    let(:no_user_event) { FactoryGirl.create :generic_event, message: 'blop', data: {"user" => nil } }
    let(:event) { FactoryGirl.create :open_studios_signup_event, message: 'blop', data: {"user" => artist.id } }

    it { expect(helper.link_to_user(no_user_event)).to eql '' }
    it 'links to the artist' do
      link_text = helper.link_to_user(event)
      expect(link_text).to eql(link_to artist.id, artist_path(artist.id))
    end
  end
end
