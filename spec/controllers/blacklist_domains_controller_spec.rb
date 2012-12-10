require 'spec_helper'

include AuthenticatedTestHelper

describe BlacklistDomainsController do
  fixtures :users, :roles_users, :roles
  context 'authorization' do
    [:index].each do |endpoint|
      describe 'not logged in' do
        describe endpoint do
          before do
            get endpoint
          end
          it_should_behave_like 'not authorized'
        end
      end
      describe 'logged in as plain user' do
        describe endpoint do
          before do
            login_as(users(:maufan1))
            get endpoint
          end
          it_should_behave_like 'not authorized'
        end
      end
      it "#{endpoint} responds success if logged in as admin" do
        login_as :admin
        get endpoint
        response.should be_success
      end
    end
  end
  
end
