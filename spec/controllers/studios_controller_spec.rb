require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe StudiosController do

  fixtures :users, :studios, :artist_infos, :art_pieces

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
      it "sets view_mode to name" do
        assigns(:view_mode).should == 'name'
      end
      
      context "with view mode set to count" do
        before do
          get :index, :v => 'c'
        end
        it "sets view_mode to count" do
          assigns(:view_mode).should == 'count'
        end
        it "studios are sorted by count descending" do
          artist_count = assigns(:studios_by_count).map{|s| s.artists.active.count}
          min = artist_count.first
          artist_count.each do |ct|
            ct.should <= min
            min = ct
          end
        end
      end
    end
    context "while logged in as an art fan" do
      integrate_views
      before do
        u = users(:maufan1)
        login_as(users(:maufan1))
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
  
  describe "#show" do
    integrate_views
    describe 'individual studio' do
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
      it "studio url is a link" do
        response.should have_tag("div.url a[href=#{studios(:as).url}]")
      end
      it "studio includes cross street if there is one" do
        Studio.any_instance.stubs(:cross_street => 'fillmore')
        get :show, :id => studios(:as).id
        response.should have_tag('.address', /\s+fillmore/)
      end
      it "studio info includes a phone if there is one" do
        Studio.any_instance.stubs(:phone => '1234569999')
        get :show, :id => studios(:as).id
        response.should have_tag('.phone', :text => '(123) 456-9999')
      end
    end
    Studio.all.each do |s|
      describe "studio fixture #{s.name}" do
        before do
          get :show, :id => s.id
        end
        it 'get\'s a list of active artists with art' do
        assigns(:artists).map(&:id).should == s.artists.active.select{|a| a.representative_piece}.map(&:id)
        end
        it 'get\'s a list of active artists with no art' do
          assigns(:other_artists).map(&:id).should == s.artists.active.select{|a| !a.representative_piece}.map(&:id)
        end
      end
    end
  end    
end
