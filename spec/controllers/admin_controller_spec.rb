require 'spec_helper'

include AuthenticatedTestHelper
include OsHelper

class TestOsHelperClass; include OsHelper; end

describe AdminController do
  use_transactional_fixtures = true
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :roles
  fixtures :studios
  fixtures :media
  fixtures :users, :roles_users

  context 'authorization' do
    [:index, :os_status, :featured_artist, :fans, :emaillist, :artists_per_day, :art_pieces_per_day, :favorites_per_day, :db_backups, :os_signups].each do |endpoint|
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
      it "#{endpoint} responds success if logged in as admin" do
        login_as :admin
        get endpoint
        response.should be_success
      end
    end
  end

  describe '#featured_artist' do
    context 'as editor' do
      before do
        login_as :editor
        get :featured_artist
      end
      it_should_behave_like 'returns success'
    end
    context 'as manager' do
      before do
        login_as :manager
        get :featured_artist
      end
      it_should_behave_like 'not authorized'
    end
  end

  describe '#emaillist' do
    before do
      login_as(:admin)
    end
    render_views
    describe 'html' do
      describe 'with no params' do
        before do
          get :emaillist
        end
        it 'returns success' do
          response.should be_success
        end
        it 'assigns the title' do
          assigns(:title).should eql "Activated"
        end
        it 'assigns list of artists emails' do
          assigns(:emails).length.should eql Artist.active.count
        end
        it 'shows the list selector' do
          assert_select '.list_chooser'
        end
        it 'shows the title and error block' do
          assert_select '.email_lists h4', "Activated [%s]" % Artist.active.count
        end
        it 'has the correct emails in the text box' do
          Artist.active.each do |a|
            assert_select '.email_results textarea', /#{a.get_name}/
            assert_select '.email_results textarea', /#{a.email}/
          end
        end
      end
      it 'assigns a list of fans emails when we ask for the fans list' do
        get :emaillist, :listname => 'fans'
        assigns(:emails).length.should eql MAUFan.all.count
      end
      it 'assigns a list of pending artists emails when we ask for the pending list' do
        get :emaillist, :listname => 'pending'
        assigns(:emails).length.should eql Artist.pending.count
      end
      Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
        it "assigns a list of os artists for #{ostag} when we ask for the #{ostag} list" do
          get :emaillist, :listname => ostag
          assigns(:emails).length.should eql Artist.active.all.select{|a| a.os_participation[ostag]}.count
        end
      end
      it 'shows the title and list size and correct emails when we ask for fans' do
        get :emaillist, :listname => 'fans'
        assert_select '.email_lists h4', 'Fans [%s]' % MAUFan.count
        MAUFan.all.each do |f|
          assert_select '.email_results textarea', /#{f.get_name}/
          assert_select '.email_results textarea', /#{f.email}/
        end
      end
      it 'shows the title and list size and correct emails when we ask for pending' do
        get :emaillist, :listname => 'pending'
        assert_select '.email_lists h4', 'Pending [%s]' % Artist.pending.count
        Artist.pending.each do |f|
          assert_select '.email_results textarea', /#{f.get_name}/
          assert_select '.email_results textarea', /#{f.email}/
        end
      end
      Conf.open_studios_event_keys.map(&:to_s).each do |ostag|
        it "shows the title and list size and correct emails when we ask for #{ostag}" do
          get :emaillist, :listname => ostag
          expected_participants = Artist.active.all.select{|a| a.os_participation[ostag]}
          expected_tag = TestOsHelperClass.new.os_pretty(ostag)
          assert_select '.email_lists h4', "#{expected_tag} [#{expected_participants.count}]"
          expected_participants.each do |f|
            assert_select '.email_results textarea', /#{f.get_name}/
            assert_select '.email_results textarea', /#{f.email}/
          end
        end
      end
      describe 'multiple os keys' do
        before do
          get :emaillist, '201004' => 'on', '201010' => 'on'
        end
        it 'the emails list is an intersection of all artists in those open studios groups' do
          emails = Artist.all.select{|a| a.os_participation['201004']}.map(&:email) |
            Artist.all.select{|a| a.os_participation['201010']}.map(&:email)
          emails.should eql assigns(:emails).map{|em| em[:email]}
        end
        it 'the emails list is an intersection of all artists in those open studios groups' do
          emails = Artist.all.select{|a| a.os_participation['201004']}.map(&:email) |
            Artist.all.select{|a| a.os_participation['201010']}.map(&:email)
          emails.should eql assigns(:emails).map{|em| em[:email]}
          emails.each do |em|
            assert_select '.email_results textarea', /#{em}/
          end
        end
      end
    end
    describe 'csv' do
      before do
        get :emaillist, :format => :csv
      end
      it 'returns success' do
        response.should be_success
      end
      it 'returns success' do
        response.content_type.should eql 'text/csv'
      end
    end
  end

  describe "#index" do
    render_views
    before do
      login_as(:admin)
      get :index
    end
    it_should_behave_like 'logged in as admin'
    it 'assigns stats hash' do
      assigns(:activity_stats).should be_a_kind_of(Hash)
    end
    it 'assigns correct values for artists yesterday' do
      assigns(:activity_stats)[:yesterday][:artists_activated].should eql 1
      assigns(:activity_stats)[:yesterday][:artists_added].should eql 1
    end
    it 'assigns correct values for artists last weeek' do
      assigns(:activity_stats)[:last_week][:artists_activated].should eql 4
      assigns(:activity_stats)[:last_week][:artists_added].should eql 7
    end
    it 'assigns correct values for artists last month' do
      assigns(:activity_stats)[:last_30_days][:artists_activated].should eql 6
      assigns(:activity_stats)[:last_30_days][:artists_added].should eql 12
    end
    it 'has totals' do
      assigns(:activity_stats)[:total].should be
    end
    it 'has studio count' do
      assigns(:activity_stats)[:total][:studios].should eql 4
    end
    it 'has event info' do
      assigns(:activity_stats)[:total][:events_past].should eql Event.past.count
      assigns(:activity_stats)[:total][:events_future].should eql Event.future.count
    end
    it 'has open studios info' do
      assigns(:activity_stats)[:open_studios].length.should >= 5
    end
    it 'has place holders for the graphs' do
      assert_select('.section.graph', :count => 4)
    end
    [:total, :yesterday, :last_week, :last_30_days, :open_studios].each do |sxn|
      it "renders an #{sxn} stats section" do
        assert_select('.section.%s' % sxn)
      end
    end
    it 'renders open studios info in reverse chrono order' do
      css_select('.section.open_studios li').first.to_s.should match /#{pretty_print_os_tag(Conf.open_studios_event_keys.sort.last)}/
      css_select('.section.open_studios li').last.to_s.should match /#{pretty_print_os_tag(Conf.open_studios_event_keys.sort.first)}/
    end
    it 'renders the current open studios setting' do
      css_select('.section.open_studios .current').first.to_s.should match /#{pretty_print_os_tag}/
    end
  end
  describe '#fans' do
    before do
      login_as(:admin)
      get :fans
    end
    it { response.should be_success }
    it {  response.should render_template 'fans' }
    it "assigns fans" do
      assigns(:fans).length.should eql User.active.all(:conditions => 'type <> "Artist"').length
    end
  end

  describe 'palette' do
    before do
      login_as(:admin)
      get :palette
    end
    it{ response.should be_success }
  end

  describe "json endpoints" do
    [:artists_per_day, :favorites_per_day, :art_pieces_per_day, :os_signups].each do |endpoint|
      describe endpoint do
        before do
          login_as(:admin)
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
      # simulate migration
      sql = "delete from featured_artist_queue"
      ActiveRecord::Base.connection.execute sql
      sql = "insert into featured_artist_queue(artist_id, position) (select id, rand() from users where type='Artist' and activated_at is not null and state='active')"
      ActiveRecord::Base.connection.execute sql

      login_as(:admin)
      FeaturedArtistQueue.not_yet_featured.all(:limit => 3).each_with_index {|fa, idx| fa.update_attributes(:featured => Time.zone.now - (2*idx).weeks) }
      get :featured_artist
    end
    it { response.should be_success }
    it "renders the featured_artist template" do
      response.should render_template 'featured_artist'
    end
    it "assigns the featured artist and the featured queue entry" do
      assigns(:featured).should be_present
      assigns(:featured_artist).should be_present
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
        response.should redirect_to '/admin/featured_artist'
      end
      it "tries to get the next artist from the queue" do
        FeaturedArtistQueue.should_receive(:next_entry).once
        FeaturedArtistQueue.should_receive(:current_entry).once
        post :featured_artist
      end
      context 'immediately after setting a featured artist' do
        before do
          get :featured_artist
        end
        it "renders the featured_artist template" do
          response.should render_template :featured_artist
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
      login_as(:admin)
      get :os_status
    end
    it 'returns success' do
      response.should be_success
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
        login_as(:admin)
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
          it { response.should redirect_to(admin_path(:action => :db_backups)) }
        end
        context 'with bad filename args' do
          before do
            get :fetch_backup, :name => 'blow'
          end
          it { response.should redirect_to(admin_path(:action => :db_backups)) }
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
          render_views
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

  let(:art_pieces_per_day) { AdminController.new.send(:compute_art_pieces_per_day) }
  let(:artists_per_day) { AdminController.new.send(:compute_artists_per_day) }
  describe "helpers" do

    describe "compute_artists_per_day" do
      it "returns an array" do
        artists_per_day.should be_a_kind_of(Array)
        artists_per_day.should have_at_least(6).items
      end
      it "returns an entries have date and count" do
        entry = artists_per_day.first
        entry.should have(2).entries
        (Time.zone.at(entry[0].to_i).to_date - Artist.active.all(:order => :created_at).last.created_at.to_date).should < 1.day
        entry[1].should >= 1
      end
      it "does not include nil dates" do
        artists_per_day.all?{|apd| !apd[0].nil?}.should be
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

        ArtPiece.any_instance.stub(:artist => double(Artist,:id => 42, :emailsettings => {'favorites' => false}))
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
        Time.zone.at(entry[0].to_i).utc.to_date.should eql Favorite.all(:order => :created_at).last.created_at.utc.to_date
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
      it "returns an entries have date and count" do
        entry = art_pieces_per_day.first
        entry.should have(2).entries
        Time.zone.at(entry[0].to_i).utc.to_date.should eql 2.hours.ago.utc.to_date
        entry[1].should >= 1
      end
      it "does not include nil dates" do
        art_pieces_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
  end
end
