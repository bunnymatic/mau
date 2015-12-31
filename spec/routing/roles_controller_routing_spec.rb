require 'rails_helper'

describe 'RolesController Routes' do
  describe 'routing' do
    it "should recognize DELETE /users/10/roles/3 as destroy role on user" do
      expect({:delete => "/users/10/roles/3"}).
        to route_to({:controller => Admin::RolesController, :action => 'destroy', :user_id => '10', :id => '3' })
    end
  end
end
