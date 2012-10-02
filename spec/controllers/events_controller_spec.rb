require 'spec_helper'

describe EventsController do

  fixtures :users, :studios, :artist_infos, :roles, :roles_users
  describe 'authorization' do
    [:edit, :new].each do |endpt|
      context "#{endpt}" do
        before do 
          get :endpt
        end
        it_should_behave_like 'login required'
      end
    end
      
    [:admin_index, :publish, :unpublish].each do |endpt|
      context "#{endpt}" do
        before do 
          get :endpt
        end
        it_should_behave_like 'not authorized'
      end
    end
  end
end
