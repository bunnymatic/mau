require 'spec_helper'

describe SearchController do

  def letter_frequency(words)
    Hash.new(0).tap do |letters|
      [words].flatten.compact.join.downcase.gsub(/\s+/,'').each_char {|c| letters[c] += 1 }
    end.sort_by{|letter, ct| ct}
  end

  let(:studios) { FactoryGirl.create_list :studio, 4 }
  let(:artists) {
    FactoryGirl.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios_search.first) +
    FactoryGirl.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios_search.last)
  }
  let(:media_search) { artists.map{|a| a.art_pieces.map(&:medium) }.flatten.compact[0..1] }
  let(:studios_search) { studios[0..1] }

  let(:studio_artist_name_match) do
    f = letter_frequency(studios_search.map(&:artists).flatten.map(&:full_name))
    f.last.first
  end

  before do
    fix_leaky_fixtures
    artists
  end

  describe "#index" do
    context "finding by studio" do
      before do
        get :index, studios: studios_search.map(&:id), keywords: studio_artist_name_match
      end
      it 'returns results' do
        expect(assigns(:paginator).items).to be_present
      end
      it 'checks the studios you searched for' do
        assigns(:query).studios.should have(2).studios
      end
    end

    context "finding by medium" do
      before do
        get :index, mediums: media_search.map(&:id), keywords: studio_artist_name_match
      end
      it 'returns results' do
        expect(assigns(:paginator).items).to be_present
      end
      it 'checks the media you searched for' do
        assigns(:query).mediums.should have(2).media
      end
    end
  end

  describe '#fetch' do
    before do
      @artist = FactoryGirl.create(:artist, :active, :with_art, nomdeplume: 'Fancy Pants')
    end
    context 'simple keyword query' do
      before do
        post :fetch, keywords: 'fancy pants'
      end
      it "returns some results" do
        assigns(:paginator).items.should have_at_least(1).art_piece
      end
      it "sets the correct page" do
        assigns(:paginator).current_page.should eql 0
      end
      it "sets the correct result count" do
        assigns(:paginator).count.should eql ArtPiece.find_all_by_artist_id(@artist.id).count
      end
    end

    context 'with per_page set' do
      before do
        post :fetch, keywords: 'name1', per_page: 48
      end
      it 'resets the per_page to something reasonable' do
        assigns(:query).per_page.should_not eql 48
      end
    end
  end
end
