require 'spec_helper'

describe EventsController do

  render_views
  let!(:events) { FactoryGirl.create_list(:event, 2, :published) + FactoryGirl.create_list(:event, 2) }
  let(:event) { events.first }
  let(:editor) { FactoryGirl.create(:artist, :editor) }
  let(:artist) { FactoryGirl.create(:artist, :active) }

  before do
    # do mobile
    request.stub(:user_agent => IPHONE_USER_AGENT)
  end
  describe "index" do
    before do
      get :index, :format => :mobile
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it 'shows a list of published events' do
      assert_select 'li.mobile-menu', :count => Event.published.count
    end
    it 'the list is ordered by reverse starttime' do
      assigns(:events).map(&:starttime).should be_monotonically_decreasing
    end
  end

  describe "#show" do
    before do
      get :show, :id => event, :format => :mobile
    end
    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"
    it 'the reception time is not shown for an event without a reception' do
      css_select('.event .reception_time').should be_empty
    end
    it 'the reception time is shown for an event with a reception' do
      event.update_attribute :reception_starttime, event.starttime
      get :show, :id => event.id
      assert_select('.event .reception_time', /Reception\:/);
    end
  end
end
