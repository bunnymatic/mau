require 'spec_helper'

describe ApplicationEvent do
  fixtures :application_events

  it 'serializes the data field' do
    ApplicationEvent.all.any?{|ae| ae.data}.should be_true, 'you need some application events with data in your fixtures'
    ApplicationEvent.all.select{|ae| ae.data}.each do |ae|
      ae.data.keys.should_not be_empty
    end
  end

  it 'functions as an STI table' do
    OpenStudiosSignupEvent.all.should eql ApplicationEvent.where(:type => 'OpenStudiosSignupEvent').to_a
  end

  it 'sends events to subscribers after save' do
    Messager.any_instance.should_receive(:publish)
    OpenStudiosSignupEvent.create(:message => 'this is a new open studios event')
  end
end
