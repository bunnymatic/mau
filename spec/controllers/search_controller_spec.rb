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
  before do
    Rails.cache.stubs(:read).returns(nil)
  end
  
  shared_examples_for 'search page with results' do
    it 'has search controls' do
      assert_select '.lcol .refine_controls'
      assert_select '.lcol .current_search'
    end
    ["Mediums", "Add Keyword(s)", "Studio", "Open Studios Artist"].each do |sxn|
      it "has blocks in refine your search for #{sxn}" do
        assert_select ".refine_controls .block h5", sxn + ":"
      end
    end
    it 'has search results' do
      assert_select '#search_results'
    end
  end

  describe "#index" do
    integrate_views
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
    end
    [:annafizyta, :artist1].each do |artist|
      %w[ firstname lastname login fullname].each do |term|
        context "for #{artist} by #{term}" do
          before do
            @artist = users(artist)
            get :index, :keywords => @artist.send(term)
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
            get :index, :keywords => @artist.send(term) + " "
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
            get :index, :keywords => @artist.send(term).capitalize
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
            get :index, :keywords => @artist.send(term).upcase
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
        get :index, :keywords => @ap.title
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
        get :index, :keywords => q
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
        get :index, :keywords => @ap.title.split.first
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
        get :index, :keywords => @tag.name
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
        get :index, :medium => @searched_medium.map(&:id), :keywords => 'title'
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
  end
end
