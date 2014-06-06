require 'spec_helper'

def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

describe ArtPieceTagsController do

  fixtures :users, :roles, :roles_users, :art_piece_tags, :art_pieces_tags, :art_pieces, :artist_infos, :media

  describe '#index' do
    describe 'format=html' do
      context 'when there are no tags' do
        before do
          ArtPieceTag.stub(:frequency => nil)
          get :index
        end
        it_should_behave_like 'renders error page'
      end
      context 'when there are tags' do

        before do
          get :index
        end
        it 'redirects to show page with the most popular tag' do
          expect(response).to redirect_to art_piece_tag_path(art_piece_tags(:one))
        end
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
    end
  end

  describe '#autosuggest' do
    before do
      Rails.cache.delete(Conf.autosuggest['tags']['cache_key'])
      get :autosuggest, :format => "json", :input => 'tag'
    end
    it_should_behave_like 'successful json'
    it 'returns all tags as json' do
      j = JSON.parse(response.body)
      j.all?(&:present?).should be_true
    end

    it 'writes to the cache if theres nothing there' do
      Rails.cache.should_receive(:read).and_return(nil)
      Rails.cache.should_receive(:write)
      get :autosuggest, :format => :json, :input => 'tag'
    end

    it 'returns tags using the input' do
      get :autosuggest, :format => :json, :input => 'this'
      j = JSON.parse(response.body)
      j.should include 'this is the tag'
    end

    it 'uses the cache there is data' do
      Rails.cache.should_receive(:read).with(Conf.autosuggest['tags']['cache_key']).
        and_return([ {"info" => ArtPieceTag.first.id, "value" => ArtPieceTag.last.name }])
      Rails.cache.should_not_receive(:write)
      get :autosuggest, :format => :json, :input => 'tag'
      j = JSON.parse(response.body)
      j.first.should eql ArtPieceTag.last.name
    end
  end

  describe '#show' do
    render_views

    it 'redirects to root on mobile' do
      @controller.stub(:is_mobile? => true)
      get :show, :id => 4
      expect(response).to redirect_to root_path
    end

    context 'for different tags' do
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

    it 'grabs the next page' do
      @tag = art_piece_tags(:one)
      get :show, :id => @tag.id, :p => 1
    end
    it_should_behave_like 'returns success'
  end

end
