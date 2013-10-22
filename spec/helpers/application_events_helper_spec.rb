require 'spec_helper'

describe ApplicationEventsHelper do
  fixtures :application_events
  describe 'link_to_user' do
    it { helper.link_to_user(application_events(:unknown_user)).should eql '' }
    it 'links to the artist' do
      link_text = helper.link_to_user(application_events(:jesseponce_os_signup))
      link_text.should eql (link_to 'jesseponce', artist_path(:id => "jesseponce"))
    end
  end
end
