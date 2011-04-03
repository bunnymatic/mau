require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe StudiosController do

  fixtures :users, :studios

  describe "#index" do
    context "while not logged in" do
      integrate_views
      before do
        get :index
      end
      it_should_behave_like "not logged in"
      it "last studio should be independent studios" do
        assigns(:studios).last.name.should == 'Independent Studios'
      end
      it "studios are in alpha order by our fancy sorter (ignoring the) with independent studios at the end" do
        s = assigns(:studios)
        s.pop
        s.sort{|a,b| a.name.downcase.gsub(/^the\ /, '') <=> b.name.downcase.gsub(/^the\ /,'')}.map(&:name).should == s.map(&:name)
      end

    end
    context "while logged in as an art fan" do
      integrate_views
      before do
        u = users(:aaron)
        login_as(users(:aaron))
        @logged_in_user = u
        get :index
      end
      it_should_behave_like "logged in user"
    end
  end

  
  describe "#show keyed studios" do

    integrate_views

    Hash[Studio.all.map{|s| [s.name.parameterize('_').to_s, s.name]}].each do |k,v|
      it "should return studio #{v} for key #{k}" do
        get :show, :id => k
        response.should have_tag('h4', :text => v)
      end
    end
  end
  
  describe "#show by id" do
    before do
      get :show, :id => studios(:as).id
    end
    it "last studio should be independent studios" do
      assigns(:studios).last.name.should == 'Independent Studios'
    end
    it "studios are in alpha order by our fancy sorter (ignoring the) with independent studios at the end" do
      s = assigns(:studios)
      s.pop
      s.sort{|a,b| a.name.downcase.gsub(/^the\ /, '') <=> b.name.downcase.gsub(/^the\ /,'')}.map(&:name).should == s.map(&:name)
    end
  end    
end
