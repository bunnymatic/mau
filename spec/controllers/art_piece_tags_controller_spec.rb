require 'spec_helper'

include AuthenticatedTestHelper

def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

describe ArtPieceTagsController do
  fixtures :users, :roles_users, :art_piece_tags, :art_pieces_tags, :art_pieces, :artist_infos, :media

  [:admin_index, :new].each do |endpoint|
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
    it "responds success if logged in as admin" do
      login_as(users(:admin))
      get endpoint
      response.should be_success
    end
  end

  describe '#index' do
    describe 'format=html' do
      before do
        get :index
      end
      it 'redirects to show page with the most popular tag' do
        response.should redirect_to art_piece_tag_path(art_piece_tags(:one))
      end
    end
    describe 'format=json' do
      context 'default' do
        before do
          get :index, :format => :json
        end
        it_should_behave_like 'successful json'
        it 'returns all tags as json' do
          j = JSON.parse(response.body)
          j.should have(ArtPieceTag.count).tags
        end

      end
      context 'with input suggestor' do
        before do
          get :index, :format => :json, :input => 'tag', :suggest => true
        end
        it_should_behave_like 'successful json'
        it 'returns all tags as json' do
          j = JSON.parse(response.body)
          j.first.should have_key 'info'
          j.first.should have_key 'value'
          j.map{|entry| entry['value'] =~ /tag/i}.all?.should be_true
        end

        it 'writes to the cache if theres nothing there' do
          Rails.cache.should_receive(:read).and_return(nil)
          Rails.cache.should_receive(:write)
          get :index, :format => :json, :input => 'tag', :suggest => true
        end

        it 'returns tags using the input' do
          get :index, :format => :json, :input => 'this', :suggest => true
          j = JSON.parse(response.body)
          tag_names = j.map{|entry| entry['value']}
          tag_names.should eql ['this is the tag']
        end

        it 'uses the cache there is data' do
          Rails.cache.should_receive(:read).with(Conf.autosuggest['tags']['cache_key']).
            and_return(JSON.generate([ {"info" => ArtPieceTag.first.id, "value" => ArtPieceTag.last.name }]))
          Rails.cache.should_not_receive(:write)
          get :index, :format => :json, :input => 'tag', :suggest => 'blo'
          j = JSON.parse(response.body)
          j.first['value'].should eql ArtPieceTag.last.name
        end
      end
    end

    describe '#show' do
      render_views

      it 'redirects to root on mobile' do
        @controller.stub(:is_mobile? => true)
        get :show, :id => 4
        response.should redirect_to root_path
      end

      [:one, :two, :three].each do |tag|
        before do
          @tag = art_piece_tags(tag)
          get :show, :id => @tag.id
          @disp = @tag.name.gsub(/\s+/, '&nbsp;')
        end
        it_should_behave_like 'returns success'
        it "renders the requested tag #{tag} highlighted" do
          assert_select '.tagcloud .clouditem.tagmatch', :count => 1, :text => @disp
        end
        it "renders art that has the requested tag #{tag}" do
          assert_select '.search-thumbs .artpiece_tag a', @disp
        end
      end
    end

    describe '#admin_index' do
      render_views
      before do
        login_as(users(:admin))
        get :admin_index
      end
      it_should_behave_like 'logged in as admin'
      it_should_behave_like 'returns success'
      it 'shows tag frequency' do
        assert_select '.singlecolumn table td.input-name', :match => /^\d+\.{0,1}\d+$/
      end
      it 'shows one entry per existing tag' do
        assert_select 'tr td.ct', :count => ArtPieceTag.count
      end
    end

    describe '#cleanup' do
      render_views
      before do
        login_as(users(:admin))
      end
      it 'redirects to art_piece_tags page' do
        get :cleanup
        response.should redirect_to '/admin/art_piece_tags'
      end
      it 'removes empty tags' do
        expect {
          get :cleanup
        }.to change(ArtPieceTag,:count).by(-2)
      end
    end
  end
end
