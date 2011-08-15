require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe EventsController do

  fixtures :users, :events, :roles

  [:edit, :show].each do |endpoint| 
    it "##{endpoint} should redirect to login if not logged in" do
      get endpoint
    end
  end
  [:unpublish, :publish, :admin_index].each do |endpoint|
    it "##{endpoint} requires admin - redirects to error if you're logged in as joe schmoe" do
      login_as(:jesseponce)
      get endpoint
      response.should redirect_to '/error'
    end
  end

  shared_examples_for 'event new or edit' do
    it "returns success" do
      response.should be_success
    end
    it "renders new or edit template" do
      response.should render_template 'new_or_edit'
    end
    it "does not include the publish checkbox" do
      assert_select("input#event_publish", false)
    end
  end

  describe "#new" do
    integrate_views
    before do
      login_as(:jesseponce)
      get :new
    end
    it_should_behave_like 'event new or edit'
  end

  describe "#edit" do
    integrate_views
    before do
      login_as(:jesseponce)
      @ev = Event.first
      get :edit, :id => @ev.id
    end
    it_should_behave_like 'event new or edit'
    it "renders the artists list text box with the current users' name" do
      assert_select("input#event_artist_list[value='#{users(:jesseponce).get_name}']")
    end
  end

  describe "#index" do
    before do
      get :index
    end
    it "returns success" do
      response.should be_success
    end
    it 'assigns only future published events' do
      assigns(:events).count.should == Event.future.published.count
    end
  end

  describe "#publish" do
    before do
      @before_publish = Time.now()
      login_as(:admin)
      @ev = events(:future)
      get :publish, :id => @ev.id
    end
    it "redirects to index" do
      response.should redirect_to(events_path)
    end
    it "flashes that the event has been published" do
      flash[:notice].should include "#{@ev.title} has been successfully published"
    end
    it "sets publish to now on that event" do
      @ev.reload
      @ev.publish.to_i.should be >= @before_publish.to_i
    end
  end

  describe "#unpublish" do
    before do
      login_as(:admin)
      @ev = events(:published)
      get :unpublish, :id => @ev.id
    end
    it "redirects to index" do
      response.should redirect_to(events_path)
    end
    it "flashes that the event has been unpublished" do
      flash[:notice].should include "#{@ev.title} has been successfully unpublished"
    end
    it "sets publish to nil on that event" do
      @ev.reload
      @ev.publish.should be_nil
    end
  end

  describe '#admin_index' do
    integrate_views
    before do
      login_as(:admin)
      get :admin_index
    end
    it "returns sucess" do
      response.should be_success
    end
    it 'assigns all events if you are an admin' do
      assigns(:events).count.should == Event.count
    end
    it 'shows publish buttons' do
      assert_select("a[href=#{publish_event_path(Event.first)}]")
    end
    it 'shows unpublish buttons for published events' do
      assert_select("a[href=#{unpublish_event_path(Event.published.first)}]")
    end
  end
  
end
