require 'spec_helper'
require 'pp'

include AuthenticatedTestHelper

describe SearchController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces
  fixtures :media
  fixtures :art_piece_tags
  fixtures :art_pieces_tags
  fixtures :studios
  before do
    Rails.cache.stubs(:read).returns(nil)
  end
  
  shared_examples_for 'search page with results' do
    it 'has search results' do
      assert_select '#search_results'
    end
  end

  integrate_views

  describe "#index" do
    describe "(with views)" do
      before do
        get :index, :keywords => "go fuck yourself.  this string ought to never match anything"
      end
      it_should_behave_like "not logged in"
    end
    
    context "for something we don't have" do
      before do
        get :index, :keywords => "go fuck yourself.  this string ought to never match anything"
      end
      it_should_behave_like 'search page with results'
      it "returns nothing" do
        response.should_not have_tag('.search-thumb-info')
      end
      it "show message indicating that nothing matched" do
        get :index, :keywords => "go fuck yourself.  this string ought to never match anything"
        response.should include_text("go fuck yourself")
        response.should include_text("couldn't find anything that matched")
      end
      ["Mediums", "Add Keyword(s)", "Studios", "Open Studios Artist"].each do |sxn|
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
      before do
        @searched_studios = [ studios(:s1890), studios(:as) ]
        get :index, :studio => @searched_studios.map(&:id), :keywords => 'title'
      end
      it_should_behave_like 'search page with results'
      it 'shows the studios you searched for' do
        assert_select '.current_search .block.studios li', :count => 2 do |tag|
          tag.to_s.should match /#{studios(:s1890).name}/
            tag.to_s.should match /#{studios(:as).name}/
        end
      end
      it 'checks the studios you searched for' do
        p assigns(:studios)
        assigns(:studios).should have(2).studios
        
        assert_select '.refine_controls .cb_entry input[checked=checked]', :count => assigns(:studios).count
      end
    end

    context "finding by medium" do
      before do
        @searched_medium = [ media(:medium1), media(:medium2) ]
        get :index, :medium => @searched_medium.map(&:id), :keywords => 'title'
      end
      it_should_behave_like 'search page with results'
      it 'shows the media you searched for' do
        assert_select '.current_search .block.mediums li', :count => 2 do |tag|
          tag.to_s.should match /#{media(:medium1).name}/
          tag.to_s.should match /#{media(:medium2).name}/
        end
      end
      it 'checks the media you searched for' do
        assigns(:mediums).should have(2).media
        assert_select '.refine_controls .cb_entry input[checked=checked]', :count => assigns(:mediums).count
      end
    end
  end

  describe '#fetch' do
    [:annafizyta, :artist1].each do |artist|
      %w[ firstname lastname fullname].each do |term|
        context "for #{artist} by #{term}" do
          before do
            @artist = users(artist)
            post :fetch, :keywords => @artist.send(term)
          end
          it_should_behave_like 'search page with results'
          it "returns some results" do
            assigns(:pieces).should have_at_least(1).art_piece
          end
          it "artist 1 owns all the art in those results" do
            assigns(:pieces).each do |ap|
              ap.artist.id.should == @artist.id
            end
          end
        end
      end

      %w[ firstname lastname fullname].each do |term|
        context "finds artists even if there are extra spaces in the query using #{artist}.#{term}" do
          before do
            @artist = users(artist)
            post :fetch, :keywords => @artist.send(term) + " "
          end
          it_should_behave_like 'search page with results'
          it "returns some results" do
            assigns(:pieces).should have_at_least(1).art_piece
          end
          it "artist 1 owns all the art in those results" do
            assigns(:pieces).each do |ap|
              ap.artist.id.should == @artist.id
            end
          end
        end
      end

      %w[firstname lastname fullname].each do |term|
        context "capitalization of search term for #{artist}.#{term}" do
          before do
            @artist = users(artist)
            post :fetch, :keywords => @artist.send(term).capitalize
          end
          it_should_behave_like 'search page with results'
          it "returns some results" do
            assigns(:pieces).should have_at_least(1).art_piece
          end
          it "artist 1 owns all the art in those results" do
            assigns(:pieces).each do |ap|
              ap.artist.id.should == @artist.id
            end
          end
        end
      end
      %w[firstname lastname fullname].each do |term|
        context "uppercase of search term for #{artist}.#{term}" do
          before do
            @artist = users(artist)
            post :fetch, :keywords => @artist.send(term).upcase
          end
          it_should_behave_like 'search page with results'
          it "returns some results" do
            assigns(:pieces).should have_at_least(1).art_piece
          end
          it "artist 1 owns all the art in those results" do
            assigns(:pieces).each do |ap|
              ap.artist.id.should == @artist.id
            end
          end
        end
      end
    end
    context "finding by art piece title" do
      before do
        @ap = ArtPiece.last
        post :fetch, :keywords => @ap.title
      end
      it_should_behave_like 'search page with results'
      it "returns 1 result" do
        results = assigns(:pieces)
        results.should have(1).art_piece
        results.first.title.should == @ap.title
      end
    end
    context "find by 2 keywords which match the artist first name and a tag" do
      before do
        q = [art_piece_tags(:two).name, users(:joeblogs).firstname].join(", ")
        post :fetch, :keywords => q
      end
      it_should_behave_like 'search page with results'
      it "returns at least 1 result" do
        assigns(:pieces).should have_at_least(1).art_piece
      end
      it "all pieces should have the artist name 'joe' and the right tag info" do
        assigns(:pieces).each do |pc|
          pc.tags.map(&:name).join(" ").should include art_piece_tags(:three).name
          pc.artist.get_name.should include 'joe'
        end
      end
    end

    context "finding by art piece partial title" do
      before do
        @ap = ArtPiece.last
        post :fetch, :keywords => @ap.title.split.first
      end
      it_should_behave_like 'search page with results'
      it "returns at least 1 result" do
        results = assigns(:pieces)
        results.should have_at_least(1).art_piece
        results.map(&:title).should include @ap.title
      end
    end
    context "finding by tag" do
      before do
        @tag = art_piece_tags(:one)
        post :fetch, :keywords => @tag.name
      end
      it_should_behave_like 'search page with results'
      it "returns at least 1 result" do
        results = assigns(:pieces)
        results.should have_at_least(1).art_piece
        results.map(&:tags).flatten.compact.map(&:id).flatten.should include @tag.id
      end
    end
      
    context "finding by medium" do
      before do
        @searched_medium = [ media(:medium1), media(:medium2) ]
        post :fetch, :medium => @searched_medium.map(&:id), :keywords => 'title'
      end
      it_should_behave_like 'search page with results'
      it "returns at least 1 result" do
        results = assigns(:pieces)
        results.should have_at_least(1).art_piece
        results.map(&:title).should include 'negative title'
      end
      it 'all results should be from one of the included mediums' do
        results = assigns(:pieces)
        results.map(&:medium_id).should have_at_least(1).medium_id
        results.map(&:medium_id).each do |m|
          @searched_medium.map(&:id).should include m
        end
      end
    end

    context "finding by studio" do
      before do
        @searched_studios = [ studios(:s1890), studios(:as) ]
        post :fetch, :studio => @searched_studios.map(&:id), :keywords => 'title'
      end
      it_should_behave_like 'search page with results'
      it "returns at least 1 result" do
        results = assigns(:pieces)
        results.should have_at_least(1).art_piece
        results.map(&:title).should include 'negative title'
      end
      it 'all results should be from one of the included studios' do
        results = assigns(:pieces).flatten
        results.should have_at_least(1).piece
        results.map(&:artist).map(&:studio_id).select{|s| s > 0}.each do |s|
          @searched_studios.map(&:id).should include s
        end
      end
    end

    context "finding by independent studio" do
      before do
        post :fetch, :studio => ['0'], :keywords => 'title'
      end
      it_should_behave_like 'search page with results'
      it "returns at least 1 result" do
        results = assigns(:pieces)
        results.should have_at_least(1).art_piece
        results.map(&:title).should include 'hotter title'
      end
      it 'all results should be from one of the included studios' do
        results = assigns(:pieces).flatten
        results.should have_at_least(1).piece
        results.map(&:artist).map(&:studio_id).uniq.should == [0]
      end
    end

    context 'finding by openstudios status' do
      before do
        @searched_studios = [ studios(:s1890), studios(:as) ]
      end
      it 'returns artists both doing and not doing open studios with nothing' do
        post :fetch, :os_artist => nil, :keywords => 'a'
        results = assigns(:pieces).flatten
        doing, notdoing = results.map(&:artist).partition(&:doing_open_studios?)
        doing.should have_at_least(1).artist
        notdoing.should have_at_least(1).artist
      end
      it 'returns artists doing open studios given os_artist = 1' do
        post :fetch, :os_artist => 1, :keywords => 'a'
        results = assigns(:pieces).flatten
        doing, notdoing = results.map(&:artist).partition(&:doing_open_studios?)
        doing.should have_at_least(1).artist
        notdoing.should be_empty
      end
      it 'returns artists not doing open studios given os_artist = 0' do
        post :fetch, :os_artist => 2, :keywords => 'a'
        results = assigns(:pieces).flatten
        doing, notdoing = results.map(&:artist).partition(&:doing_open_studios?)
        doing.should be_empty
        notdoing.should have_at_least(1).artist
      end
    end

  end
end
