require 'rails_helper'

describe AdminController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:pending_artist) { FactoryGirl.create(:artist, :with_studio, state: 'pending', nomdeplume: "With A'Postr") }
  let(:artist) { FactoryGirl.create(:artist, :with_studio) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:editor) { FactoryGirl.create(:artist, :editor) }
  let(:manager) { FactoryGirl.create(:artist, :manager, :with_studio) }
  let(:artist2) { manager }

  include OpenStudiosEventShim

  context 'authorization' do
    [:index, :os_status, :featured_artist, :fans ].each do |endpoint|
      describe 'not logged in' do
        describe endpoint.to_s do
          before do
            get endpoint
          end
          it_should_behave_like 'not authorized'
        end
      end
      describe 'logged in as plain user' do
        describe endpoint.to_s do
          before do
            login_as fan
            get endpoint
          end
          it_should_behave_like 'not authorized'
        end
      end
      it "#{endpoint} responds success if logged in as admin" do
        login_as admin
        get endpoint
        expect(response).to be_success
      end
    end
  end

  describe '#featured_artist' do
    context 'as editor' do
      before do
        login_as editor
        get :featured_artist
      end
      it { expect(response).to be_success }
    end
    context 'as manager' do
      before do
        login_as manager
        get :featured_artist
      end
      it_should_behave_like 'not authorized'
    end
  end

  describe '#fans' do
    before do
      login_as admin
      get :fans
    end
    it { expect(response).to be_success }
    it { expect(response).to render_template 'fans' }
    it "assigns fans" do
      expect(assigns(:fans).length).to eql (User.active.count - Artist.active.count)
    end
  end

  describe 'palette' do
    before do
      login_as admin
      allow_any_instance_of(ScssFileReader).to receive(:parse_colors).and_return([['black', '000'], ['white', 'ffffff']])
      get :palette
    end
    it{ expect(response).to be_success }
  end

  describe '#featured_artist' do
    before do

      FeaturedArtistQueue.create!( position: rand, artist_id: artist.id )
      FeaturedArtistQueue.create!( position: rand, artist_id: artist2.id )
      FactoryGirl.create_list(:artist, 3, :active).each do |artst|
        FeaturedArtistQueue.create!( position: rand, artist_id: artst.id )
      end

      login_as admin
      FeaturedArtistQueue.not_yet_featured.limit(3).each_with_index do |fa, idx|
        fa.update_attributes(featured: (Time.zone.now - (2*idx).weeks))
      end
      get :featured_artist
    end
    it { expect(response).to be_success }
    it "renders the featured_artist template" do
      expect(response).to render_template 'featured_artist'
    end
    it "assigns the featured artist and the featured queue entry" do
      expect(assigns(:featured)).to be_a_kind_of(FeaturedArtistQueue)
    end
    context "#post" do
      it "redirects to the featured_artist page" do
        post :featured_artist
        expect(response).to redirect_to '/admin/featured_artist'
      end
      it "tries to get the next artist from the queue" do
        expect(FeaturedArtistQueue).to receive(:next_entry).once
        post :featured_artist
      end
      context 'immediately after setting a featured artist' do
        before do
          get :featured_artist
        end
        it "renders the featured_artist template" do
          expect(response).to render_template :featured_artist
        end
        it "post with override gets the next artist" do
          expect {
            post :featured_artist, override: true
          }.to change(FeaturedArtistQueue.featured, :count).by(1)
        end
      end
    end
  end

  describe '#os_status' do
    before do
      login_as admin
      get :os_status
    end
    it 'returns success' do
      expect(response).to be_success
    end
    it 'sets a list of artists in alpha order by last name' do
      assigns(:os).length == Artist.active.count
      expect(assigns(:os).map(&:lastname).map(&:downcase)).to be_monotonically_increasing
      expect(assigns(:totals).count).to eql 9
    end
  end

end
