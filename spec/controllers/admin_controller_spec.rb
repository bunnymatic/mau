require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe AdminController do
  use_transactional_fixtures = true
  fixtures :studios
  fixtures :media
  fixtures :users
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :roles

  [:index, :featured_artist, :fans, :emaillist, :artists_per_day, :roles, :art_pieces_per_day, :favorites_per_day, :db_backups].each do |endpoint|
    describe 'not logged in' do
      describe endpoint do
        before do
          get endpoint
        end
        it_should_behave_like 'not authorized'
      end
    end
    describe 'logged in as plain user' do
      describe endpoint do
        before do
          login_as(users(:maufan1))
          get endpoint
        end
        it_should_behave_like 'not authorized'
      end
    end
    it "responds success if logged in as admin" do
      login_as(:admin)
      get endpoint
      response.should be_success
    end
  end

  describe "#index" do
    describe 'without views' do
      before do
        login_as(:admin)
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
        assigns(:activity_stats)[:last_week][:artists_activated].should == 4
        assigns(:activity_stats)[:last_week][:artists_added].should == 7
      end
      it 'assigns correct values for artists last month' do
        assigns(:activity_stats)[:last_30_days][:artists_activated].should == 5
        assigns(:activity_stats)[:last_30_days][:artists_added].should == 12
      end
      it 'has totals' do
        assigns(:activity_stats)[:total].should be
      end
      it 'has studio count' do
        assigns(:activity_stats)[:total][:studios].should == 4
      end
      it 'has event info' do
        assigns(:activity_stats)[:total][:events_past].should == Event.past.count
        assigns(:activity_stats)[:total][:events_future].should == Event.future.count
      end
    end
    describe 'with views' do
      integrate_views
      before do
        login_as(:admin)
        get :index
      end
      it 'has place holders for the graphs' do
        response.should have_tag('.section.graph', :count => 3)
      end
    end
  end
  describe '#fans' do
    before do
      login_as(:admin)
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
      login_as(:admin)
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
          login_as(:admin)
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
        login_as(:admin)
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
        login_as(:admin)
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
        login_as(:admin)
        get :featured_artist
        response.should have_tag('#get_next_featured')
      end
    end
    context "#post" do
      integrate_views
      before do
        @featured_count = FeaturedArtistQueue.featured.count
        login_as(:admin)
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

  context 'database backups' do 
    before do
      @tmpdir = File.join(Dir.tmpdir, "backups")
      Dir.mkdir(@tmpdir) unless File.exists?(@tmpdir)
    end
    context "logged in" do
      before do
        login_as(:admin)
      end
      describe "#fetch_backup" do 
        integrate_views
        before do
          File.open("#{@tmpdir}/file1.tgz",'w'){ |f| f.write('.tgz dump file contents') }
          Dir.stubs(:glob => ["#{@tmpdir}/file1.tgz", "#{@tmpdir}/file2.tgz"])
          get :fetch_backup, :name => "file1.tgz"
        end
        it "returns the file contents as text" do
          response.body.class.should == Proc
        end
      end
      describe '#db_backups' do
        before do
          File.open("#{@tmpdir}/file1.tgz",'w'){ |f| f.write('.tgz dump file contents') }
          sleep(2)
          File.open("#{@tmpdir}/file2.tgz",'w'){ |f| f.write('.tgz dump file contents2') }
          Dir.stubs(:glob => ["#{@tmpdir}/file1.tgz", "#{@tmpdir}/file2.tgz"])
        end
        context 'without views' do
          before do
            get :db_backups
          end
          it "returns success" do
            response.should be_success
          end
          it 'finds a list of database files' do
            assigns(:dbfiles).should be_a_kind_of(Array)
          end
          it "files are in descending cronological order" do
            files = assigns(:dbfiles)
            files[1].path.should include 'file1.tgz'
          end
        end
        context 'with views' do
          integrate_views
          before do
            get :db_backups
          end
          it "includes named links to the database dump files" do
            assigns(:dbfiles).each do |f|
              link = admin_path(:action => 'fetch_backup', :name => File.basename(f.path))
              assert_select("li a[href=#{link}]", /#{f.ctime.strftime("%b %d, %Y %H:%M")}/)
              assert_select("li a[href=#{link}]", /\d+\s+MB/)

            end
          end
        end
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
        (Time.at(entry[0].to_i).to_date - Artist.active.all(:order => :created_at).last.created_at.to_date).should < 1.day
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
        
        a1 = ArtPiece.first
        a1.artist = users(:artist1)
        a1.save
        a2 = ArtPiece.last
        a2.artist = users(:artist1)
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
