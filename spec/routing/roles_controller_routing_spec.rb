require 'spec_helper'

describe 'RolesController Routes' do
  describe 'routing' do
    it "should recognize DELETE /users/10/roles/3 as destroy role on user" do
      {:delete => "/users/10/roles/3"}.should route_to({:controller => 'roles', :action => 'destroy', :user_id => '10', :id => '3' })
    end
  end
end
