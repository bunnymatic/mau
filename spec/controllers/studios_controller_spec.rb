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
    describe 'json' do
      before do
        get :index, :format => 'json'
      end
      it 'returns success' do
        response.should be_success
      end
      it 'returns json' do
        response.content_type.should == 'application/json'
      end
      it 'returns all studios' do
        j = JSON.parse(response.body)
        j.count.should == Studio.all.count
      end
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
      describe 'html' do
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

      describe 'json' do
        before do
          get :show, :id => studios(:as).id, :format => 'json'
        end
        it_should_behave_like 'returns success'
        it 'returns json' do
          response.content_type.should == 'application/json'
        end
        it 'returns the studio data' do
          j = JSON.parse(response.body)
          j['studio']['name'].should == studios(:as).name
          j['studio']['street'].should == studios(:as).street
        end
        it 'includes a list of artist ids' do
          j = JSON.parse(response.body)
          j['studio']['artists'].should be_a_kind_of Array
        end
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
  describe 'destroy' do
    describe 'unauthorized' do 
      before do 
        delete :destroy, :id => Studio.all[2].id
      end
      it_should_behave_like 'not authorized'
    end
    describe 'as admin' do
      before do
        login_as(:admin)
      end
      it 'deletes the studio' do
        expect { delete :destroy, :id => Studio.all[2] }.to change(Studio, :count).by(-1)
      end
      it 'sets artists\' to indy for all artists in the deleted studio' do
        s = Studio.all[2]
        artist_ids = s.artists.map(&:id)
        assert(artist_ids.length > 0, 'You need to have a couple artists on that studio in your fixtures')
        delete :destroy, :id => s.id
        users = User.find(artist_ids)
        users.all?{|a| a.studio_id == 0}.should be_true, 'Not all the artists were moved into the "Indy" studio'
      end
    end

  end
end
