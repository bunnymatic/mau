require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

def setup_admin_user
  u = users(:admin)
  u.roles << roles(:admin)
  u.save
  u
end

describe AdminController do
  use_transactional_fixtures = true
  fixtures :studios
  fixtures :media
  fixtures :users
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :roles

  [:index, :featured_artist, :fans, :emaillist, :artists_per_day, :roles, :art_pieces_per_day, :favorites_per_day].each do |endpoint|
    describe endpoint do
      it "responds failure if not logged in" do
        get endpoint
        response.should redirect_to '/error'
      end
      it "responds failure if not logged in as admin" do
        login_as(users(:maufan1))
        get endpoint
        response.should redirect_to '/error'
      end
      it "responds success if logged in as admin" do
        login_as(setup_admin_user)
        get endpoint
        response.should be_success
      end
    end
  end

  describe "#index" do
    integrate_views
    before do
      login_as(setup_admin_user)
      get :index
    end
    it 'returns success' do
      response.should be_success
    end
    it 'assigns stats hash' do
      assigns(:activity_stats).should be_a_kind_of(Hash)
    end
    it 'assigns correct values for artists yesterday' do
      assigns(:activity_stats)[:yesterday][:artists_activated].should == 1
      assigns(:activity_stats)[:yesterday][:artists_added].should == 1
    end
    it 'assigns correct values for artists last weeek' do
      assigns(:activity_stats)[:last_week][:artists_activated].should == 2
      assigns(:activity_stats)[:last_week][:artists_added].should == 5
    end
    it 'assigns correct values for artists last month' do
      assigns(:activity_stats)[:last_30_days][:artists_activated].should == 3
      assigns(:activity_stats)[:last_30_days][:artists_added].should == 8
    end
    it 'has totals' do
      assigns(:activity_stats)[:total].should be
    end
    it 'has studio count' do
      assigns(:activity_stats)[:total][:studios].should == 4
    end
    it 'has place holders for the graphs' do
      response.should have_tag('.section.graph', :count => 3)
    end
  end
  describe '#fans' do
    before do
      login_as(setup_admin_user)
      get :fans
    end
    it "responds success" do
      response.should be_success
    end
    it "renders fans template" do
      response.should render_template 'fans'
    end
    it "assigns fans" do
      assigns(:fans).length.should == User.active.all(:conditions => 'type <> "Artist"').length
    end
  end
  describe '#roles' do
    before do
      login_as(setup_admin_user)
      get :roles
    end
    it "responds success" do
      response.should be_success
    end
    it "renders roles" do
      response.should render_template 'roles'
    end
    it "assigns artists" do
      assigns(:users).should have(User.active.count).users
    end
    it 'assigns roles' do
      assigns(:roles).should have(Role.count).roles
    end
    it 'assigns roles' do
      assigns(:users_in_roles).keys.should have(Role.count).roles
    end
    context "(view tests)" do
      integrate_views
      
      Role.all.each do |r|
        it "has the role #{r} in a list element" do
          response.should have_tag 'li .role', :count => Role.count
        end
      end
    end
  end

  describe "json endpoints" do
    [:artists_per_day, :favorites_per_day, :art_pieces_per_day].each do |endpoint|
      describe endpoint do
        before do 
          login_as(setup_admin_user)
          xhr :get, endpoint
        end
        it "returns success" do
          response.should be_success
        end
        it "returns json" do
          response.content_type.should == 'application/json'
        end
        it "json is ready for flotr" do
          j = JSON.parse(response.body)
          j.keys.should include 'series'
          j.keys.should include 'options'
        end
      end
    end
  end

  describe '#featured_artist' do
    before do 
      # simulate migration 
      sql = "delete from featured_artist_queue"
      ActiveRecord::Base.connection.execute sql
      sql = "insert into featured_artist_queue(artist_id, position) (select id, rand() from users where type='Artist' and activated_at is not null and state='active')"
      ActiveRecord::Base.connection.execute sql
    end
    context "w/o views" do
      before do
        login_as(setup_admin_user)
        get :featured_artist
      end
      it "renders the featured_artist template" do
        response.should render_template 'featured_artist'
      end
      it "returns success" do
        response.should be_success
      end
      it "assigns the featured artist and the featured queue entry" do
        assigns(:featured).should be_present
        assigns(:featured_artist).should be_present
        assigns(:featured).should be_a_kind_of(FeaturedArtistQueue)
        assigns(:featured_artist).should be_a_kind_of(Artist)
      end
    end
    context "with views" do
      integrate_views
      before do
        # set a few artists as featured
        FeaturedArtistQueue.not_yet_featured.all(:limit => 3).each_with_index {|fa, idx| fa.update_attributes(:featured => Time.now - (2*idx).weeks) }
        login_as(setup_admin_user)
        get :featured_artist
      end
      it "includes previously featured artists" do
        response.should have_tag('.previously_featured li', :count => 2)
      end
      it 'has no button to get the next featured artist if the most recent featured artist was featured less than 1 week ago' do
        response.should_not have_tag('#get_next_featured')
      end
      it 'includes a button to get the next featured artist if it\'s more than 1 week since the last one' do
        FeaturedArtistQueue.featured.each_with_index {|fa, idx| fa.update_attributes(:featured => Time.now - (2*(1+idx)).weeks) }
        login_as(setup_admin_user)
        get :featured_artist
        response.should have_tag('#get_next_featured')
      end
    end
    context "#post" do
      integrate_views
      before do
        @featured_count = FeaturedArtistQueue.featured.count
        login_as(setup_admin_user)
        post :featured_artist
      end
      it "returns success" do
        response.should be_success
      end
      it "renders the featured_artist template" do
        response.should render_template :featured_artist
      end
      it "tries to get the next artist from the queue" do
        FeaturedArtistQueue.featured.count.should == (@featured_count + 1)
      end
      it "calling it again flashes a warning" do
        post :featured_artist
        response.should have_tag('.featured .error-msg')
      end
    end
  end

  describe "helpers" do
    describe "compute_artists_per_day" do
      before do
        @artists_per_day = AdminController.new.send(:compute_artists_per_day)
      end
      it "returns an array" do
        @artists_per_day.should be_a_kind_of(Array)
        @artists_per_day.should have_at_least(6).items
      end
      it "returns an entries have date and count" do
        entry = @artists_per_day.first
        entry.should have(2).entries
        Time.at(entry[0].to_i).to_date.should == Artist.active.all(:order => :created_at).last.created_at.to_date
        entry[1].should >= 1
      end
      it "does not include nil dates" do
        @artists_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
    describe "compute_favorites_per_day" do
      before do
        u1 = users(:maufan1)
        u2 = users(:jesseponce)
        u3 = users(:annafizyta)
        
        artist = users(:artist1)
        artist.artist_info = artist_infos(:artist1)
        artist.save
        
        a1 = ArtPiece.first
        a1.artist = artist
        a1.save
        a2 = ArtPiece.last
        a2.artist = artist
        a2.save
        
        ArtPiece.any_instance.stubs(:artist => stub(:id => 42, :emailsettings => {'favorites' => false}))
        u1.add_favorite a1
        u1.add_favorite users(:artist1)
        u1.add_favorite u2
        u2.add_favorite a1
        u2.add_favorite users(:artist1)
        u3.add_favorite a2
        
        @favorites_per_day = AdminController.new.send(:compute_favorites_per_day)
      end
      it "returns an array" do
        @favorites_per_day.should be_a_kind_of(Array)
        @favorites_per_day.should have(1).item
      end
      it "returns an entries have date and count" do
        entry = @favorites_per_day.first
        entry.should have(2).entries
        Time.at(entry[0].to_i).to_date.should == Favorite.all(:order => :created_at).last.created_at.to_date
        entry[1].should >= 1
      end
      it "does not include nil dates" do
        @favorites_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
    describe "compute_art_pieces_per_day" do
      before do
        @art_pieces_per_day = AdminController.new.send(:compute_art_pieces_per_day)
      end
      it "returns an array" do
        @art_pieces_per_day.should be_a_kind_of(Array)
        @art_pieces_per_day.should have_at_least(6).items
      end
      it "returns an entries have date and count" do
        entry = @art_pieces_per_day.first
        entry.should have(2).entries
        Time.at(entry[0].to_i).to_date.should == 2.hours.ago.to_date
        entry[1].should >= 1
      end
      it "does not include nil dates" do
        @art_pieces_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
  end

end
