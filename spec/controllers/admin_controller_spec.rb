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
    [:index, :os_status, :featured_artist, :fans,
     :emaillist, :db_backups].each do |endpoint|
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

  describe '#emaillist' do
    before do
      login_as admin
    end

    describe 'html' do
      context 'with no params' do
        before do
          get :emaillist
        end
        it 'returns success' do
          expect(response).to be_success
        end
        it 'assigns the title' do
          expect(assigns(:email_list).title).to eql "Activated"
        end
        it 'assigns list of artists emails' do
          expect(assigns(:email_list).emails.length).to eql Artist.active.count
        end
      end

      describe 'multiple os keys' do
        before do
          get :emaillist, '201004' => 'on', '201010' => 'on'
        end
        it 'sets up the correct list name' do
          expect(assigns(:email_list).list_names).to eql(['201004','201010'])
        end
      end

      [:all, :active, :pending, :no_images, :no_profile ].each do |list_name|
        describe "list name = #{list_name}" do
          before do
            get :emaillist, 'listname' => list_name
          end
          it 'sets the right list name' do
            expect(assigns(:email_list).list_names).to eql [list_name.to_s]
          end
        end
      end
    end

    describe 'csv' do
      let(:parse_args) { ApplicationController::DEFAULT_CSV_OPTS.merge({headers:true}) }
      let(:parsed) { CSV.parse(response.body, parse_args) }
      before do
        pending_artist
        get :emaillist, format: :csv, listname: 'pending'
      end
      it { expect(response).to be_success }
      it { expect(response).to be_csv_type }
      it 'includes the right headers' do
        past_os_event_keys = %w|201004 201010 201104 201110 201204 201210 201304 201310 201404|
        expected_headers = ["First Name","Last Name","Full Name","Email Address","Group Site Name"]
        expected_headers += past_os_event_keys
        expect(parsed.headers).to eq(expected_headers)
      end
      it 'includes the right data' do
        expect(parsed.length).to eql 1
        expect(parsed.first["Full Name"]).to eql pending_artist.full_name
        expect(parsed.first["Group Site Name"]).to eql pending_artist.studio.name
      end

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
        before do
          File.open("#{tmpdir}/file1.tgz",'w'){ |f| f.write('.tgz dump file contents') }
        end
        context 'with good args' do
          before do
            allow(Dir).to receive(:glob).and_return(["#{tmpdir}/file1.tgz", "#{tmpdir}/file2.tgz"])
            get :fetch_backup, name: "file1.tgz"
          end
          it "returns the file" do
            expect(response.content_type).to eql 'application/octet-stream'
            expect(response.headers['Content-Disposition']).to include 'attachment'
            expect(response.headers['Content-Disposition']).to include 'file1.tgz'
          end
        end
        context 'with no args' do
          before do
            get :fetch_backup
          end
          it { expect(response).to redirect_to(admin_path(action: :db_backups)) }
        end
        context 'with bad filename args' do
          before do
            get :fetch_backup, name: 'blow'
          end
          it { expect(response).to redirect_to(admin_path(action: :db_backups)) }
        end
      end
      describe '#db_backups' do
        before do
          File.open("#{tmpdir}/file1.tgz",'w'){ |f| f.write('.tgz dump file contents') }
          File.open("#{tmpdir}/file2.tgz",'w'){ |f| f.write('.tgz dump file contents2') }
          allow(Dir).to receive(:glob).and_return(["#{tmpdir}/file1.tgz", "#{tmpdir}/file2.tgz"])
        end
        context 'without views' do
          before do
            get :db_backups
          end
          it "returns success" do
            expect(response).to be_success
          end
          it 'finds a list of database files' do
            expect(assigns(:dbfiles)).to be_a_kind_of(Array)
          end
          it "includes all files" do
            expect(assigns(:dbfiles).size).to eq(2)
          end
        end
      end
    end
  end
end
