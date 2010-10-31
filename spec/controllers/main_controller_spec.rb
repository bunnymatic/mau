require 'spec_helper'

include AuthenticatedTestHelper

describe MainController do
  describe "- route generation" do
  end
  describe "- route recognition" do
    it "should generate {:controller=>main, action=>venues} from ANY 'venues'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/venues").should == {:controller => 'main', :action => 'venues' }
      end
    end
    it "should generate {:controller=>main, action=>getinvolved} from ANY 'getinvolved'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/getinvolved").should == {:controller => 'main', :action => 'getinvolved' }
      end
    end
    it "should generate {:controller=>main, action=>about} from ANY 'about'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/about").should == {:controller => 'main', :action => 'about' }
      end
    end
    it "should generate {:controller=>main, action=>privacy} from ANY 'privacy'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/privacy").should == {:controller => 'main', :action => 'privacy' }
      end
    end
    it "should generate {:controller=>main, action=>contact} from ANY 'contact'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/contact").should == {:controller => 'main', :action => 'contact' }
      end
    end
    it "should generate {:controller=>main, action=>news} from ANY 'news'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/news").should == {:controller => 'main', :action => 'news' }
      end
    end

  end
end

