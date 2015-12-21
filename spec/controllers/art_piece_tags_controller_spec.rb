require 'spec_helper'

describe ArtPieceTagsController do

  let(:artists) { FactoryGirl.create_list(:artist, 3, :with_tagged_art) }
  let(:artist) { artists.first }
  let(:tags) { artist.art_pieces.map(&:tags).flatten }
  let(:tag) { tags.first }

  before do
    fix_leaky_fixtures
    artists
  end

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
          expect(response).to redirect_to art_piece_tag_path(tag)
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
          j = JSON.parse(response.body)['art_piece_tags']
          j.should have(ArtPieceTag.count).tags
        end
      end
    end
  end

  describe '#autosuggest' do
    before do
      get :autosuggest, :format => "json", :input => tags.first.name.downcase
    end
    it_should_behave_like 'successful json'
    it 'returns all tags as json' do
      j = JSON.parse(response.body)
      j.all?(&:present?).should be_true
    end

    it 'writes to the cache if theres nothing there' do
      Rails.cache.should_receive(:read).and_return(nil)
      Rails.cache.should_receive(:write)
      get :autosuggest, :format => :json, :input => 'whateverdude'
    end

    it 'returns tags using the input' do
      get :autosuggest, :format => :json, :input => tags.first.name.downcase
      j = JSON.parse(response.body)
      j.should be_present
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
    before do
      tags
    end
    context 'for different tags' do
      before do
        get :show, :id => tag.id
      end
      it { expect(response).to be_success }
    end

    context 'for an unknown tag' do
      before do
        get :show, :id => 'abc5'
      end
      it 'redirects to the most popular tag' do
        expect(response).to redirect_to art_piece_tag_path(tag)
      end
    end

  end

end
