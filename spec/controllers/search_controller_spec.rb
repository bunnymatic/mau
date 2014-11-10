require 'spec_helper'

describe SearchController do


  let(:open_studios_event) { FactoryGirl.create(:open_studios_event) }
  let(:nomdeplume_artist) { Artist.active.where(nomdeplume:'Interesting').first }
  let(:studios) { FactoryGirl.create_list :studio, 4 }
  let(:artists) {
    FactoryGirl.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios.first) +
    FactoryGirl.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios.last)
  }
  let(:artist) { artists.first }
  let(:art_piece) { artist.art_pieces.first }
  let(:medium) { art_piece.medium }
  let(:tag) { art_piece.tags.last }
  let(:media_search) { artists.map{|a| a.art_pieces.map(&:medium) }.flatten.compact[0..1] }
  let(:studios_search) { studios[0..1] }
  let(:open_studio_event) { FactoryGirl.create(:open_studios_event) }

  before do
    fix_leaky_fixtures
    artists.sample(2).map{|a| a.update_os_participation open_studios_event.key, true}
    studios
  end

  shared_examples_for 'search page with results' do
    it 'has search results' do
      assert_select '#search_results'
    end
  end

  render_views

  describe "#index" do
    describe "(with views)" do
      before do
        get :index
      end
      it_should_behave_like "not logged in"
      it 'includes display data on the studio and medium inputs' do
        assert_select '#medium_chooser input[data-display]'
        assert_select '#studio_chooser input[data-display]'
      end
      it "puts the keywords back in no results report" do
        assert_select '.no-results', match: 'match your query'
      end
    end

    context "for something we don't have" do
      let(:keywords) { 'move along.  this string should not match anything' }
      before do
        get :index, keywords: keywords
      end
      it_should_behave_like 'search page with results'
      it "returns nothing" do
        css_select('.search-thumb-info').should be_empty
      end
      it "puts the keywords back in the search box" do
        assert_select '#keywords' do |tag|
          tag[0].attributes['value'].should eql keywords
        end
      end
      it "show message indicating that nothing matched" do
        response.body.should include("move along")
        response.body.should include("couldn't find anything that matched")
      end
      it "has blocks in refine your search for sub sections" do
        ["Mediums", "Add Keyword(s)", "Studios", "Open Studios Participants"].each do |sxn|
          assert_select ".refine_controls h5.block_head", sxn + ":"
        end
      end
      it 'has search controls' do
        assert_select '.lcol .refine_controls'
        assert_select '.lcol .current_search'
      end
    end

    context "finding by studio" do
      before do
        get :index, studios: studios_search.map(&:id), keywords: 'title'
      end
      it_should_behave_like 'search page with results'
      it 'shows the studios you searched for' do
        assert_select '.current_search .block.studios li', count: 2 do |tag|
          items = tag.map(&:to_s).join
          studios_search.each do |s|
            items.should match s.name
          end
        end
      end
      it 'checks the studios you searched for' do
        assigns(:query).studios.should have(2).studios
        assert_select '.refine_controls .cb_entry input[checked=checked]', count: assigns(:query).studios.count
      end
    end

    context "finding by medium" do
      before do
        get :index, mediums: media_search.map(&:id), keywords: 'title'
      end
      it_should_behave_like 'search page with results'
      it 'shows the media you searched for' do
        assert_select '.current_search .block.mediums li', count: 2 do |tag|
          items = tag.map(&:to_s).join
          items.should match /#{media_search.first.name}/
          items.should match /#{media_search.last.name}/
        end
      end
      it 'checks the media you searched for' do
        assigns(:query).mediums.should have(2).media
        assert_select '.refine_controls .cb_entry input[checked=checked]', count: assigns(:query).mediums.count
      end
    end
  end

  describe '#fetch' do
    before do
      @artist = FactoryGirl.create(:artist, :active, :with_art, nomdeplume: 'Fancy Pants')
      post :fetch, keywords: 'fancy pants'
    end
    it_should_behave_like 'search page with results'
    it "returns some results" do
      assigns(:paginator).items.should have_at_least(1).art_piece
    end
    it "sets the correct page" do
      assigns(:paginator).current_page.should eql 0
    end
    it "sets the correct result count" do
      assigns(:paginator).count.should eql ArtPiece.find_all_by_artist_id(@artist.id).count
    end

    context 'finding by openstudios status' do
      before do
        post :fetch, os_artist: nil, keywords: 'name1'
      end
      it 'shows open studios stars as appropriate' do
        assert_select '.os-star', count: 6
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
