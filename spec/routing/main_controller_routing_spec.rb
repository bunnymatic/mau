require 'spec_helper'

describe 'MainController Routes' do
  [:status, :faq, :openstudios, :venues, :privacy, :about, :history, :contact, :version].each do |endpoint|
    it "routes #{endpoint} to the main##{endpoint}" do
      { :get => "/#{endpoint}" }.should route_to({:controller => 'main', :action => endpoint.to_s})
    end
  end
end
