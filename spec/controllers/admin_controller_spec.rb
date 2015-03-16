require 'spec_helper'

describe AdminController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:pending_artist) { FactoryGirl.create(:artist, :with_studio, state: 'pending') }
  let(:artist) { FactoryGirl.create(:artist, :with_studio) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:editor) { FactoryGirl.create(:artist, :editor) }
  let(:manager) { FactoryGirl.create(:artist, :manager, :with_studio) }
  let(:artist2) { manager }

  include OpenStudiosEventShim

  context 'authorization' do
    [:index, :os_status, :featured_artist, :fans,
     :emaillist, :artists_per_day, :art_pieces_per_day,
     :favorites_per_day, :db_backups, :os_signups].each do |endpoint|
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

  describe '#emaillist' do
    before do
      login_as admin
    end
    render_views

    describe 'html' do
      context 'with no params' do
        before do
          get :emaillist
        end
        it 'returns success' do
          expect(response).to be_success
        end
        it 'assigns the title' do
          assigns(:email_list).title.should eql "Activated"
        end
        it 'assigns list of artists emails' do
          assigns(:email_list).emails.length.should eql Artist.active.count
        end
        it 'shows the list selector' do
          assert_select '.list_chooser'
        end
        it 'shows the title and error block' do
          assert_select '.email_lists h4', "Activated [%s]" % Artist.active.count
        end
        it 'has the correct emails in the text box' do
          Artist.active.each do |a|
            assert_select '.email_results table tbody tr td', /#{a.get_name}/
            assert_select '.email_results table tbody tr td', /#{a.email}/
          end
        end
      end

      describe 'multiple os keys' do
        before do
          get :emaillist, '201004' => 'on', '201010' => 'on'
        end
        it 'sets up the correct list name' do
          assigns(:email_list).list_names.should eql(['201004','201010'])
        end
      end

      [:all, :active, :pending, :no_images, :no_profile ].each do |list_name|
        describe "list name = #{list_name}" do
          before do
            get :emaillist, 'listname' => list_name
          end
          it 'sets the right list name' do
            assigns(:email_list).list_names.should eql [list_name.to_s]
          end
        end
      end
    end

    describe 'csv' do
      let(:parse_args) { ApplicationController::DEFAULT_CSV_OPTS.merge({:headers =>true}) }
      let(:parsed) { CSV.parse(response.body, parse_args) }
      before do
        pending_artist
        get :emaillist, :format => :csv, :listname => 'pending'
      end
      it { expect(response).to be_success }
      it { expect(response).to be_csv_type }
      it 'includes the right headers' do
        expected_headers = ["First Name","Last Name","Full Name","Email Address","Group Site Name"]
        expected_headers += Conf.open_studios_event_keys.map(&:to_s)
        parsed.headers.should == expected_headers
      end
      it 'includes the right data' do
        expect(parsed.length).to eql 1
        expect(parsed.first["Full Name"]).to eql pending_artist.full_name
        expect(parsed.first["Group Site Name"]).to eql pending_artist.studio.name
      end

    end
  end

  describe "#index" do
    render_views
    before do
      FactoryGirl.create(:open_studios_event)
      FactoryGirl.create(:open_studios_event, start_date: 6.months.ago)
      FactoryGirl.create(:open_studios_event, start_date: 12.months.ago)
      login_as admin
      get :index
    end
    it 'has place holders for the graphs' do
      assert_select('.graph', :count => 4)
    end
    it 'renders the different stats sections' do
      assert_select('.dashboard__stats-list.totals')
      assert_select('.dashboard__stats-list.yesterday')
      assert_select('.dashboard__stats-list.last_week')
      assert_select('.dashboard__stats-list.last_30_days')
      assert_select('.dashboard__stats-list.open_studios')
    end
    it 'renders open studios info in reverse chrono order' do
      first_tag = OpenStudiosEvent.for_display available_open_studios_keys.first
      last_tag = OpenStudiosEvent.for_display available_open_studios_keys.last
      css_select('.open_studios li').first.to_s.should match /#{first_tag}/
      css_select('.open_studios li').last.to_s.should match /#{last_tag}/
    end
    it 'renders the current open studios setting' do
      first_tag = OpenStudiosEvent.current.for_display
      css_select('.open_studios .current').first.to_s.should match /#{first_tag}/
    end
  end
  describe '#fans' do
    before do
      login_as admin
      get :fans
    end
    it { expect(response).to be_success }
    it {  expect(response).to render_template 'fans' }
    it "assigns fans" do
      assigns(:fans).length.should eql User.active.all(:conditions => 'type <> "Artist"').length
    end
  end

  describe 'palette' do
    before do
      login_as admin
      ScssFileReader.any_instance.stub(:parse_colors => [['black', '000'], ['white', 'ffffff']])
      get :palette
    end
    it{ expect(response).to be_success }
  end

  describe "json endpoints" do
    before do
      login_as admin
    end

    [:artists_per_day, :favorites_per_day, :art_pieces_per_day, :os_signups].each do |endpoint|
      describe endpoint do
        before do
          xhr :get, endpoint
        end
        it_should_behave_like 'successful json'
        it "json is ready for flotr" do
          j = JSON.parse(response.body)
          j.keys.should include 'series'
          j.keys.should include 'options'
        end
      end
    end
  end

  describe '#featured_artist' do
    render_views
    before do

      FeaturedArtistQueue.create!( position: rand, artist_id: artist.id )
      FeaturedArtistQueue.create!( position: rand, artist_id: artist2.id )
      FactoryGirl.create_list(:artist, 3, :active).each do |artst|
        FeaturedArtistQueue.create!( position: rand, artist_id: artst.id )
      end

      login_as admin
      FeaturedArtistQueue.not_yet_featured.all(:limit => 3).each_with_index do |fa, idx|
        fa.update_attributes(:featured => Time.zone.now - (2*idx).weeks)
      end
      get :featured_artist
    end
    it { expect(response).to be_success }
    it "renders the featured_artist template" do
      expect(response).to render_template 'featured_artist'
    end
    it "assigns the featured artist and the featured queue entry" do
      assigns(:featured).should be_a_kind_of(FeaturedArtistQueue)
      assigns(:featured_artist).should be_a_kind_of(Artist)
    end
    it 'includes a button to send the featured artist a note' do
      assert_select '.featured .artist_info .controls .formbutton', 'Tell me I\'m Featured'
    end
    it "includes previously featured artists" do
      assert_select('.previously_featured li', :count => 2)
    end
    it 'includes a button to get the next featured artist' do
      assert_select('#get_next_featured')
    end
    context "#post" do
      it "redirects to the featured_artist page" do
        post :featured_artist
        expect(response).to redirect_to '/admin/featured_artist'
      end
      it "tries to get the next artist from the queue" do
        FeaturedArtistQueue.should_receive(:next_entry).once
        post :featured_artist
      end
      context 'immediately after setting a featured artist' do
        before do
          get :featured_artist
        end
        it "renders the featured_artist template" do
          expect(response).to render_template :featured_artist
        end
        it 'includes an override checkbox to get the next featured artist' do
          assert_select('input#override_date')
        end
        it 'shows a warning message' do
          assert_select('.featured .warning')
        end
        it "post with override gets the next artist" do
          expect {
            post :featured_artist, :override => true
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
      assigns(:os).map(&:lastname).map(&:downcase).should be_monotonically_increasing
      assigns(:totals).count == Conf.open_studios_event_keys.count
    end
  end

  let(:tmpdir) { File.join(Dir.tmpdir, "backups") }
  context 'database backups' do
    before do
      Dir.mkdir(tmpdir) unless File.exists?(tmpdir)
    end
    context "when logged in" do
      before do
        login_as admin
      end
      describe "#fetch_backup" do
        render_views
        before do
          File.open("#{tmpdir}/file1.tgz",'w'){ |f| f.write('.tgz dump file contents') }
        end
        context 'with good args' do
          before do
            Dir.stub(:glob => ["#{tmpdir}/file1.tgz", "#{tmpdir}/file2.tgz"])
            get :fetch_backup, :name => "file1.tgz"
          end
          it "returns the file" do
            response.content_type.should eql 'application/octet-stream'
            response.headers['Content-Disposition'].should include 'attachment'
            response.headers['Content-Disposition'].should include 'file1.tgz'
          end
        end
        context 'with no args' do
          before do
            get :fetch_backup
          end
          it { expect(response).to redirect_to(admin_path(:action => :db_backups)) }
        end
        context 'with bad filename args' do
          before do
            get :fetch_backup, :name => 'blow'
          end
          it { expect(response).to redirect_to(admin_path(:action => :db_backups)) }
        end
      end
      describe '#db_backups' do
        before do
          File.open("#{tmpdir}/file1.tgz",'w'){ |f| f.write('.tgz dump file contents') }
          sleep(2)
          File.open("#{tmpdir}/file2.tgz",'w'){ |f| f.write('.tgz dump file contents2') }
          Dir.stub(:glob => ["#{tmpdir}/file1.tgz", "#{tmpdir}/file2.tgz"])
        end
        context 'without views' do
          before do
            get :db_backups
          end
          it "returns success" do
            expect(response).to be_success
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
          render_views
          before do
            get :db_backups
          end
          it "includes named links to the database dump files" do
            assigns(:dbfiles).each do |f|
              link = admin_fetch_backup_path(:name => File.basename(f.path))
              assert_select("li a[href=#{link}]", /#{f.ctime.strftime("%b %d, %Y %H:%M")}/)
              assert_select("li a[href=#{link}]", /\d+\s+MB/)
            end
          end
        end
      end
    end
  end
  describe "helpers" do
    let(:art_pieces_per_day) { AdminController.new.send(:compute_art_pieces_per_day) }
    let(:artists_per_day) { AdminController.new.send(:compute_artists_per_day) }
    before do
      Timecop.freeze
      FactoryGirl.create(:artist, :active, :with_art)
      3.times.each do |n|
        Timecop.travel (1+n).days.ago
        FactoryGirl.create(:artist, :active, :with_art)
      end
      artists_per_day
      art_pieces_per_day
    end
    after do
      Timecop.return
    end

    describe "compute_artists_per_day" do
      it "returns an array" do
        artists_per_day.should be_a_kind_of(Array)
        artists_per_day.should have(4).items
      end
      it "returns an entries have date and count" do
        entry = artists_per_day.first
        entry.should have(2).entries
        last_created_date = Artist.active.all(:order => :created_at).last.created_at.to_date
        (Time.zone.at(entry[0].to_i).to_date - last_created_date).should be < 1.day
        entry[1].should be >= 1
      end
      it "does not include nil dates" do
        artists_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
    describe "compute_favorites_per_day" do
      before do
        u1 = fan
        u2 = artist
        u3 = artist2

        a1 = ArtPiece.first
        a1.update_attribute(:artist_id, artist.id)
        a2 = ArtPiece.last
        a2.update_attribute(:artist_id, artist.id)

        artist_stub = double(Artist,:id => 42, :emailsettings => {'favorites' => false})
        ArtPiece.any_instance.stub(:artist => artist_stub)
        u1.add_favorite a1
        u1.add_favorite artist
        u1.add_favorite u2
        u2.add_favorite a1
        u2.add_favorite artist
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
        last_favorite_date = Favorite.all(:order => :created_at).last.created_at.utc.to_date
        Time.zone.at(entry[0].to_i).utc.to_date.should eql last_favorite_date
        entry[1].should >= 1
      end
      it "does not include nil dates" do
        @favorites_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
    describe "compute_art_pieces_per_day" do
      it "returns an array" do
        art_pieces_per_day.should be_a_kind_of(Array)
        art_pieces_per_day.should have_at_least(6).items
      end
      it "does not include nil dates" do
        art_pieces_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
  end

end
