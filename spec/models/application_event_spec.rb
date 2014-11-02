require 'spec_helper'

describe ApplicationEvent do

  let(:os_event) { FactoryGirl.create(:open_studios_signup_event, data: {user: 'artist'})} 

  it 'serializes the data field' do
    os_event.data.should be_a_kind_of Hash
  end

  it 'sends events to subscribers after save' do
    Messager.any_instance.should_receive(:publish)
    OpenStudiosSignupEvent.create(:message => 'this is a new open studios event')
  end
end
