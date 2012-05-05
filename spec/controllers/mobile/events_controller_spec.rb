require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../mobile_shared_spec')

describe EventsController do

  integrate_views

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :studios
  fixtures :events
  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
  end
  describe "index" do
    before do
      get :index
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"
    
    it 'shows a list of published events' do
      response.should have_tag 'li.mobile-menu', :count => Event.published.count
    end        
    it 'the list is ordered by reverse starttime' do
      assigns(:events).sort_by(&:starttime).reverse.should == assigns(:events)
    end        
  end
  

  describe "#show" do
    before do
      @event = events(:url_with_http)
      get :show, :id => @event
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"
    it 'the reception time is not shown for an event without a reception' do
      response.should_not have_tag('.event .reception_time')
    end      
    it 'the reception time is shown for an event with a reception' do
      ev = events(:reception_start)
      get :show, :id => ev.id
      assert_select('.event .reception_time', /Reception\:/);
    end      
  end
end
