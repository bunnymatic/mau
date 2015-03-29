require 'spec_helper'

describe FavoritesController do
  let(:fan) { FactoryGirl.create(:fan) }
  let(:quentin) { FactoryGirl.create :artist }
  let(:admin) { FactoryGirl.create :user, :admin, :active }
  let(:jesse) { quentin }
  let(:joe) { FactoryGirl.create :artist, :active }
  let(:artist) { FactoryGirl.create :artist, :active }
  let(:pending) { FactoryGirl.create :artist, :pending }
  let(:pending_fan) { FactoryGirl.create :fan, :pending }
  let(:art_pieces) do
    FactoryGirl.create_list :art_piece, 4, :with_tag, artist: artist
  end
  let(:art_piece) do
    art_pieces.first
  end

  before do
    stub_signup_notification
    stub_mailchimp
  end

  describe "#index" do
    render_views
    context "show" do
      context "while not logged in" do
        before do
          get :index, id: fan.id
        end
        it { expect(response).to be_success }
        it "doesn't have the no favorites msg" do
          css_select('.no-favorites-msg').should be_empty
        end
      end
      context "asking for a user that doesn't exist" do
        before do
          get :index, id: 'bogus'
        end
        it "redirects to all artists" do
          expect(response).to redirect_to artists_path
        end
        it "flashes an error" do
          flash[:error].should be_present
        end
      end
      context "while logged in as fan with no favorites" do
        let(:artist) { FactoryGirl.create(:artist) }
        before do
          art_pieces
          ArtPiece.any_instance.stub(artist: artist)
          login_as(fan)
          get :index, id: fan.id
        end
        it { expect(response).to be_success }
        it "gets some random links assigned" do
          assigns(:random_picks).size.should > 2
        end
        it "has the no favorites msg" do
          assert_select('.no-favorites-msg', count: 1)
        end
        it "has section for 'artist by name'" do
          assert_select('.favorites__random-by-name', match: 'Find Artists by Name')
        end
        it "has section for 'artist by medium'" do
          assert_select('.favorites__random-by-medium', match: 'Find Artists by Medium')
        end
        it "has section for 'artist by tag'" do
          assert_select('.favorites__random-by-tag', match: 'Find Artists by Tag')
        end
        it "does not show the favorites sections" do
          css_select('.favorites > h4').should be_empty
          css_select('.favorites > h4').should be_empty
        end
        it "doesn't show a button back to the artists page" do
          css_select('.pure-button.pure-button-primary').should be_empty
        end
      end
      context "while logged in as artist" do
        before do
          ArtPiece.any_instance.stub(artist: quentin)
          login_as(artist)
        end
        it 'returns success' do
          get :index, id: artist.id
          expect(response).to be_success
        end
        context "who has favorites" do
          before do
            User.any_instance.stub(get_profile_path: "/this")
            ArtPiece.any_instance.stub(:get_path).with('small').and_return("/this")
            ap = FactoryGirl.create(:art_piece, artist: joe)
            artist.add_favorite ap
            artist.add_favorite joe
            assert artist.favorites.count >= 1
            assert artist.fav_artists.count >= 1
            assert artist.fav_art_pieces.count >= 1
            get :index, id: artist.id
          end
          it { expect(response).to be_success }
          it "does not assign random picks" do
            assigns(:random_picks).should be_nil
          end
          it "shows the title" do
            assert_select('.title', match: 'My Favorites')
          end
          it "favorites sections show and include the count" do
            assert_select('h4', text: "Artists (#{artist.fav_artists.count})")
            assert_select("h4", text: "Art Pieces (#{artist.fav_art_pieces.count})")
          end
          it "shows the 1 art piece favorite" do
            assert_select('.favorites .art_pieces .thumb', count: 1, include: 'by blupr')
          end
          it "shows the 1 artist favorite" do
            assert_select('.favorites .artists .thumb', count: 1)
          end
          it "shows a delete button for each favorite" do
            assert_select('.favorites li .fa-trash-o', count: artist.favorites.count)
          end
          it "shows a button back to the artists page" do
            assert_select('.buttons form')
          end
        end
      end
      context "logged in as user looking at artist who has favorites " do
        before do
          User.any_instance.stub(get_profile_path: "/this")
          ArtPiece.any_instance.stub(:get_path).with('small').and_return("/this")
          FactoryGirl.create(:art_piece, artist: joe)
          artist.add_favorite joe
          artist.add_favorite joe.art_pieces.last
          assert artist.fav_artists.count >= 1
          assert artist.fav_art_pieces.count >= 1
          login_as fan
          get :index, id: artist.id
        end
        it { expect(response).to be_success }
        it "shows the title" do
          assert_select('.title', include: artist.get_name )
          assert_select('.title', include: 'Favorites')
        end
        it "shows the favorites sections" do
          assert_select('h4', include: 'Artists')
          assert_select('h4', include: 'Art Pieces')
        end
        it "shows the 1 art piece favorite" do
          assert_select('.favorites .art_pieces .thumb', count: 1)
        end
        it "shows the 1 artist favorite" do
          assert_select('.favorites .artists .thumb', count: 1)
        end
        it "does not show a delete button for each favorite" do
          css_select('.favorites li .fa-trash-o').should be_empty
        end
      end
    end
  end
end
