require 'spec_helper'

describe CalendarController do

  fixtures :users, :studios, :artist_infos, :roles, :roles_users, :events

  render_views

  describe 'index' do
    before do
      get :index
    end
    it { expect(response).to be_success }
    it 'includes the calendar html' do
      assert_select '.ec-calendar'
    end
  end

end
