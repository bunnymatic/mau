require 'spec_helper'

describe SearchController do

  before do
    Rails.cache.stub(:read => nil)
  end

  shared_examples_for 'search page with results' do
    it 'has search results' do
      assert_select '#search_results'
    end
  end

  render_views

  let(:artists) { FactoryGirl.create_list(:artist, 3, :with_studio, :with_art) }
  let(:studios) { artists.map(&:studio) }
  describe "#index" do
    describe "(with views)" do
      before do
        get :index
      end
      it_should_behave_like "not logged in"
      it 'includes display data on the medium inputs' do
        assert_select '#medium_chooser input[data-display]'
      end
      it 'includes display data on the studio inputs' do
        assert_select '#studio_chooser input[data-display]'
      end
      it "puts the keywords back in no results report" do
        assert_select '.no-results', :match => 'match your query'
      end
    end

    context "for something we don't have" do
      before do
        get :index, :keywords => "go fuck yourself.  this string ought to never match anything"
      end
      it_should_behave_like 'search page with results'
      it "returns nothing" do
        css_select('.search-thumb-info').should be_empty
      end
      it "puts the keywords back in the search box" do
        assert_select '#keywords' do |tag|
          tag[0].attributes['value'].should eql 'go fuck yourself.  this string ought to never match anything'
        end
      end
      it "show message indicating that nothing matched" do
        get :index, :keywords => "go fuck yourself.  this string ought to never match anything"
        response.body.should include("go fuck yourself")
        response.body.should include("couldn't find anything that matched")
      end
      ["Mediums", "Add Keyword(s)", "Studios", "Open Studios Participants"].each do |sxn|
        it "has blocks in refine your search for #{sxn}" do
          assert_select ".refine_controls h5.block_head", sxn + ":"
        end
      end
      it 'has search controls' do
        assert_select '.lcol .refine_controls'
        assert_select '.lcol .current_search'
      end
    end

    context "finding by studio" do
      let(:studio_search) { [ studios(:s1890), studios(:as) ] }
      before do
        get :index, :studios => studio_search.map(&:id), :keywords => 'title'
      end
      it_should_behave_like 'search page with results'
      it 'shows the studios you searched for' do
        assert_select '.current_search .block.studios li', :count => 2 do |tag|
          tag.to_s.should match /#{studios(:s1890).name}/
            tag.to_s.should match /#{studios(:as).name}/
        end
      end
      it 'checks the studios you searched for' do
        assigns(:query).studios.should have(2).studios
        assert_select '.refine_controls .cb_entry input[checked=checked]', :count => assigns(:query).studios.count
      end
    end

    context "finding by medium" do
      let(:media_search) { [ media(:medium1), media(:medium2) ] }
      before do
        get :index, :mediums => media_search.map(&:id), :keywords => 'title'
      end
      it_should_behave_like 'search page with results'
      it 'shows the media you searched for' do
        assert_select '.current_search .block.mediums li', :count => 2 do |tag|
          tag.to_s.should match /#{media(:medium1).name}/
          tag.to_s.should match /#{media(:medium2).name}/
        end
      end
      it 'checks the media you searched for' do
        assigns(:query).mediums.should have(2).media
        assert_select '.refine_controls .cb_entry input[checked=checked]', :count => assigns(:query).mediums.count
      end
    end
  end

  describe '#fetch' do
    before do
      @artist = FactoryGirl.create(:artist, :active, :with_art, nomdeplume: 'Fancy Pants')
      post :fetch, :keywords => 'Interesting'
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
      render_views
      before do
        post :fetch, :os_artist => nil, :keywords => 'a'
      end
      it 'shows open studios stars as appropriate' do
        assert_select '.os-star', :count => 8
      end
    end

    context 'with per_page set' do
      before do
        post :fetch, :keywords => 'a', :per_page => 48
      end
      it 'resets the per_page to something reasonable' do
        assigns(:query).per_page.should_not eql 48
      end
    end
  end
end
