require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'MainController Routes' do
  [:faq, :openstudios, :venues, :privacy, :about, :history, :contact, :version].each do |endpoint|
    it "routes #{endpoint} to the main##{endpoint}" do
      { :get => "/#{endpoint}" }.should route_to({:controller => 'main', :action => endpoint.to_s})
    end
  end
end
