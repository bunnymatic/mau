require 'spec_helper'

describe 'MainController Routes' do
  [:faq, :openstudios, :venues, :privacy, :about, :history, :contact, :version].each do |endpoint|
    it "routes #{endpoint} to the main##{endpoint}" do
      { :get => "/#{endpoint}" }.should route_to({:controller => 'main', :action => endpoint.to_s})
    end
  end
  it "routes status to the main#status_page" do
    { :get => "/status" }.should route_to({:controller => 'main', :action => "status_page"})
  end

end
