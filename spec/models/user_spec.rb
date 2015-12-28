require 'spec_helper'

describe User do
  let(:simple_artist) { FactoryGirl.build(:artist) }
  let(:maufan) { FactoryGirl.create(:fan, :active) }
  let(:artist) { FactoryGirl.create(:artist, :with_art, profile_image: 'profile.jpg') }
  let(:art_piece) { artist.art_pieces.first }
  let(:admin) { FactoryGirl.create(:artist, :admin, :with_art) }
  let(:manager) { FactoryGirl.create(:artist, :manager, :with_studio) }
  let(:editor) { FactoryGirl.create(:artist, :editor) }
  let(:managing_editor) { FactoryGirl.create(:artist, :manager, :editor) }
  let!(:roles) do
    FactoryGirl.create :role, :admin
    FactoryGirl.create :role, :editor
    FactoryGirl.create :role, :manager
  end

  subject(:user) { FactoryGirl.build(:user, :active) }

  before do
    Timecop.freeze
  end
  after do
    Timecop.return
  end

  it 'requires password and password confirmation' do
    user.password = ''
    user.password_confirmation = ''
    user.valid?
    expect(user).to have_at_least(1).error_on(:password)
    expect(user).to have_at_least(1).error_on(:password_confirmation)
  end

  it{ should validate_presence_of(:login) }
  it{ should validate_length_of(:login).is_at_least(5).is_at_most(40) }

  it{ should validate_presence_of(:email) }
  it{ should validate_length_of(:email).is_at_least(6).is_at_most(100) }

  it{ should validate_length_of(:firstname).is_at_most(100) }
  it{ should validate_length_of(:lastname).is_at_most(100) }

  context 'find by username or email' do
    let!(:artist) { create :artist, login: 'whatever_yo', email: 'yo_whatever@example.com' }
    it 'finds users by their login' do
      expect(User.find_by_username_or_email('whatever_yo')).to eql artist
    end
    it 'finds users by their email' do
      expect(User.find_by_username_or_email('yo_whatever@example.com')).to eql artist
    end
    it 'returns nil when there is no match' do
      expect(User.find_by_username_or_email('ack')).to be_nil
    end
  end

  context 'unique field constraints' do
    before do
      stub_signup_notification
    end
    it{ should validate_uniqueness_of(:login) }
    it{ should validate_uniqueness_of(:email) }
  end

  context 'make sure our factories work' do
    it 'creates an editor' do
      expect(FactoryGirl.create(:user, :editor, :active).is_editor?).to eq(true)
    end
    it 'creates an admin' do
      expect(FactoryGirl.create(:user, :admin, :active).is_admin?).to eq(true)
    end
  end


  describe '#sortable_name' do
    let(:user1) { FactoryGirl.create(:user, :active, firstname: nil, lastname: nil, login: 'zzzzza')}
    let(:user2) { FactoryGirl.create(:user, :active, firstname: nil, lastname: nil, login: 'bbbbbb')}
    let(:user3) { FactoryGirl.create(:user, :active, firstname: nil, lastname: nil, login: 'aaaaaa')}
    let(:artists) { [user1, user2, user3]}
    let(:sorted_artists) {
      artists.sort_by(&:sortable_name)
    }

    context 'when artists only have a login' do
      it 'should sort the artists by their login name' do
        expect(sorted_artists.first.login).to eql user3.login
        expect(sorted_artists[1].login).to eql user2.login
        expect(sorted_artists.last.login).to eql user1.login
      end
    end

    context 'when the artists last name is punctuation' do
      let(:user1) { FactoryGirl.create(:user, :active, firstname: 'RUBYSPAM', lastname: '*', login: 'aaabbb')}
      it 'should sort the artists by their login name' do
        expect(sorted_artists.first.login).to eql user3.login
        expect(sorted_artists[1].login).to eql user2.login
        expect(sorted_artists.last.login).to eql user1.login
      end
    end

    context 'when some artists have empty last names' do
       let(:user1) { FactoryGirl.create(:user, :active, firstname: 'bob', lastname: 'kabob', login: 'zzzzza')}
       let(:user2) { FactoryGirl.create(:user, :active, firstname: 'Bob', lastname: ' ', login: 'bbbbbb')}
       let(:user3) { FactoryGirl.create(:user, :active, firstname: 'faern', lastname: '', login: 'cccccc')}
       it 'should sort the artists properly' do
        expect(sorted_artists.first.login).to eql user2.login
        expect(sorted_artists[1].login).to eql user3.login
        expect(sorted_artists.last.login).to eql user1.login
      end
    end

  end
  describe '#full_name' do
    context 'an artist with a login but no names' do
      it 'returns login for full name' do
        u = FactoryGirl.build(:user, firstname: nil, lastname: nil, nomdeplume: nil)
        expect(u.full_name).to eql u.login
      end
      it 'returns first/last name for full name' do
        u = FactoryGirl.build(:user, firstname: 'yo', lastname: 'tHere', nomdeplume: nil)
        expect(u.full_name).to eql [u.firstname, u.lastname].join(' ')
      end
      it 'returns nom de plume if it\'s available' do
        u = FactoryGirl.build(:user, firstname: 'yo', lastname: 'tHere', nomdeplume: "I'm So Famous")
        expect(u.full_name).to eql u.nomdeplume
      end
    end
  end
  describe 'new' do
    it 'validates' do
      expect(user).to be_valid
    end

    context 'with a bad email' do
      it "should not allow 'bogus email' for email address" do
        user = FactoryGirl.build(:user, email: 'bogus email')
        expect(user).not_to be_valid
        expect(user).to have_at_least(1).error_on(:email)
      end

      it "should not allow '   ' for email" do
        user = FactoryGirl.build(:user, email: '  ')
        expect(user).not_to be_valid
        expect(user).to have_at_least(1).error_on(:email)
      end
      it "should not allow blow@ for email" do
        user = FactoryGirl.build(:user, email: 'blow@')
        expect(user).not_to be_valid
        expect(user).to have_at_least(1).error_on(:email)
      end
    end
  end
  describe 'create' do
    it 'sets email attrs to true for everything' do
      FactoryGirl.create(:user, :pending)
      expect(User.all.last.emailsettings.all?{|k,v| v}).to eq(true)
    end
  end
  describe 'named scope' do
    it "active returns only active users" do
      User.active.all.each do |u|
        expect(u.state).to eql 'active'
      end
    end
    it "pending returns only pending users" do
      User.pending.all.each do |u|
        expect(u.state).to eql 'pending'
      end
    end
  end

  describe 'get_name' do
    it 'returns nom de plume if defined' do
      user = FactoryGirl.build(:user, nomdeplume: 'blurp')
      expect(user.get_name).to eql 'blurp'
    end
    it 'returns first + last if defined' do
      user = FactoryGirl.build(:user, nomdeplume: nil )
      expect(user.get_name).to eql([user.firstname, user.lastname].join ' ')
    end
    it 'returns login if nom, and firstname are not defined' do
      user = FactoryGirl.build(:user, nomdeplume: '', firstname: '')
      expect(user.get_name).to eql user.login
    end
    it 'returns login if nom, and lastname are not defined' do
      user = FactoryGirl.build(:user, nomdeplume: '', lastname: '')
      expect(user.get_name).to eql user.login
    end

  end

  describe 'get_profile_image' do
    it 'returns the medium artists profile image if there is one' do
      expect(artist.get_profile_image).to eql "/artistdata/#{artist.id}/profile/m_profile.jpg"
    end
    it 'returns the small artists profile image if there is one give size = small' do
      expect(artist.get_profile_image(:small)).to eql "/artistdata/#{artist.id}/profile/s_profile.jpg"
    end
  end

  describe 'get_share_link' do
    it "returns the artists link" do
      expect(user.get_share_link).to match %r|/artists/#{user.login}$|
    end
    it "returns the html safe artists link given html_safe = true" do
      expect(user.get_share_link(true).downcase).to match %r|%2fartists%2f#{user.login}$|
    end
    it "returns the artists link with params given params" do
      expect(user.get_share_link(false, this: "that")).to match %r|artists/#{user.login}\?this=that$|
    end
  end

  describe 'roles' do
    it "without admin role user is not admin" do
      expect(artist).not_to be_is_admin
    end
    it "without editor role user is not editor" do
      expect(artist).not_to be_is_editor
    end
    it "with admin role, user is admin" do
      expect(admin).to be_is_admin
    end
    it "with editor role, user is editor" do
      expect(editor).to be_is_editor
    end
    it "with editor and manager role, user is editor and manager but not admin" do
      expect(managing_editor).to be_is_editor
      expect(managing_editor).to be_is_manager
      expect(managing_editor).not_to be_is_admin
    end
    it "with admin role, user is editor and manager and admin" do
      expect(admin).to be_is_editor
      expect(admin).to be_is_manager
      expect(admin).to be_is_admin
    end
    it 'does not save multiple roles of the same type' do
      expect {
        manager.roles << Role.where(role: :manager).first
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'address' do
    it "responds to address" do
      expect(simple_artist).to respond_to :address
    end
    it "responds to full address" do
      expect(simple_artist).to respond_to :full_address
    end
    it "returns nothing" do
      expect(simple_artist.address).not_to be_present
    end
  end
  describe "unavailable methods" do
    it "doesn't reply to old artists attributes" do
      [:lat, :lng, :bio, :street, :city, :zip].each do |method|
        expect(maufan).not_to respond_to method
      end
    end
  end

  describe 'favorites -'  do
    describe "adding artist as favorite to a user" do
      before do
        @u = maufan # he's a fan
        @a = artist
        @u.add_favorite(@a)
        @u.save
      end
      it "all users favorites should be either of type Artist or ArtPiece" do
        expect(@u.favorites.select {|f| ['Artist','ArtPiece'].include? f.favoritable_type}.size).to be >= 1
      end
      it "artist is in the users favorites list" do
        favs = @u.favorites.select { |f| f.favoritable_id == @a.id }
        expect(favs.size).to eq(1)
        expect(favs[0].favoritable_id).to eql(@a.id)
        expect(favs[0].favoritable_type).to eql('Artist')
      end
      it "artist is in the users favorite.to_obj list as an artist model" do
        fs = @u.favorites.to_obj.select { |f| f.id == @a.id }
        expect(fs.size).to eq(1)
        expect(fs[0].id).to eql @a.id
        expect(fs[0].class).to eql Artist
      end
      it "artist is in user.fav_artists list" do
        expect(@u.fav_artists.map { |a| a.id }).to include(@a.id)
      end
      it "first in user.fav_artists list is an Artist" do
        expect(@u.fav_artists.first.is_a?(User)).to be
      end
      context "and removing that artist" do
        before do
          @u.remove_favorite(@a)
        end
        it ", artist is no longer a favorite" do
          expect(@u.fav_art_pieces.size).to eq(0)
        end
      end
      context "and trying to add a duplicate artist" do
        before do
          @num_favs = @u.favorites.count
          @result = @u.add_favorite(@a)
        end
        it "doesn't add" do
          expect(@result).to be_nil
          expect(@num_favs).to eql @u.favorites.count
        end
      end
      context "then artist deactivates" do
        before do
          @aid = @a.id
          @favs = @u.favorites.count
          @a.destroy
        end
        it "fav_artists should not return deactivated artist" do
          expect(@u.fav_artists.map { |a| a.id }).not_to include(@aid)
        end
        it "favorites list should be smaller" do
          expect(@u.favorites.count).to eql @favs - 1
        end
      end
    end
    describe "narcissism" do
      it "favoriting yourself is not allowed" do
        expect(artist.add_favorite(artist)).to be_nil
      end
      it "favoriting your own art work is not allowed" do
        expect(artist.add_favorite(art_piece)).to be_nil
      end
      it "it doesn't send favorite notification" do
        expect(ArtistMailer).to receive('favorite_notification').never
        expect(artist.add_favorite(art_piece)).to be_nil
      end
    end

    describe "mailer notifications" do
      before do
        artist
      end
      it '#resend_activation sends a new activation email' do
        expect(UserMailer).to receive('resend_activation').with(maufan).once.and_return(double(:deliver! => true))
        maufan.resend_activation
      end
      it '#create_reset_code sends a recent reset email' do
        expect(UserMailer).to receive('reset_notification').with(maufan).once.and_return(double(:deliver! => true))
        maufan.create_reset_code
      end

      it "add art_piece favorite sends favorite notification to owner" do
        expect(ArtistMailer).to receive('favorite_notification').with(artist, maufan).once.and_return(double(:deliver! => true))
        maufan.add_favorite(art_piece)
      end
      it "add artist favorite sends favorite notification to user" do
        expect(ArtistMailer).to receive('favorite_notification').with(artist, maufan).once.and_return(double(:deliver! => true))
        maufan.add_favorite(artist)
      end
      it "add artist favorite doesn't send notification to user if user's email settings say no" do
        h = artist.emailsettings
        h['favorites'] = false
        artist.emailsettings = h
        artist.save!
        artist.reload
        expect(ArtistMailer).to receive('favorite_notification').with(artist, maufan).never
        maufan.add_favorite(artist)
      end
    end

    describe "adding art_piece as favorite" do
      before do
        maufan.add_favorite(art_piece)
      end
      it "all users favorites should be either of type Artist or ArtPiece" do
        expect(maufan.favorites.select {|f| ['Artist','ArtPiece'].include? f.favoritable_type}.size).to be >= 1
      end
      it "art_piece is in favorites list" do
        fs = maufan.favorites.select { |f| f.favoritable_id == art_piece.id }
        expect(fs.size).to eq(1)
        expect(fs[0].favoritable_id).to eql art_piece.id
        expect(fs[0].favoritable_type).to eql 'ArtPiece'
      end
      it "art_piece is in favorites_to_obj list as an ArtPiece" do
        fs = maufan.favorites.to_obj.select { |f| f.id == art_piece.id }
        expect(fs.size).to eq(1)
        expect(fs[0].id).to eql art_piece.id
        expect(fs[0].class).to eql ArtPiece
      end

      it "art_piece is in the artists 'fav_art_pieces' list" do
        expect(maufan.fav_art_pieces.map { |ap| ap.id }).to include(art_piece.id)
      end
      it "art piece is of type ArtPiece" do
        expect(maufan.fav_art_pieces.first.is_a?(ArtPiece)).to be
      end
      it "user does not have 'art_pieces' because he's a user" do
        expect(maufan.methods).not_to include('art_pieces')
      end

      it "doesn't add items twice" do
        expect{
          maufan.add_favorite(art_piece)
        }.to change(maufan.favorites, :count).by(0)
      end

      context "and removing it" do
        it "Favorite delete get's called" do
          expect_any_instance_of(Favorite).to receive(:destroy).exactly(:once)
          maufan.remove_favorite(art_piece)
        end
        it "art_piece is no longer a favorite" do
          f = maufan.remove_favorite(art_piece)
          expect(Favorite.where(user_id: maufan.id)).not_to include f
        end
      end
    end
  end

  describe "forgot password methods" do
    context "artfan" do
      before do
        Timecop.travel(1.hour.since)
      end
      it "create_reset_code creates a reset code" do
        expect(maufan.reset_code).to be_nil
        expect {
          maufan.create_reset_code
          expect(maufan.reset_code).not_to be_nil
        }.to change(UserMailer.deliveries, :count).by(1)
      end
    end
    context "artist" do
      it "create_reset_code creates a reset code" do
        expect(artist.reset_code).to be_nil
        artist.create_reset_code
        expect(artist.reset_code).not_to be_nil
      end
    end
  end

  describe 'field cleaner' do
    let(:simple_artist) { build :artist, firstname: '  first  ', lastname: ' _ _ _ ',  nomdeplume: ' mi nom ' }
    it 'cleans firstname, lastname and nomdeplume fields of whitespace before save' do
      simple_artist.valid?
      expect(simple_artist.firstname).to eql 'first'
    end
  end

  describe 'MailChimp includes' do
    describe "mailchimp_additional_data" do
      before do
        @mail_data = artist.send(:mailchimp_additional_data)
      end
      it 'returns allowed mapped attributes' do
        expected_keys =  ['FNAME','LNAME', 'CREATED']
        expect(@mail_data.keys.length).to eql expected_keys.length
        expect(@mail_data.keys.all?{|k| expected_keys.include? k}).to be
      end
      it 'returns correct values for mapped attributes' do
        expect(@mail_data['CREATED']).to eql artist.activated_at
        expect(@mail_data['FNAME']).to eql artist.firstname
        expect(@mail_data['LNAME']).to eql artist.lastname
      end
    end
    describe 'subscribe and welcome' do
      before do
        artist
        expect_any_instance_of(Artist).to receive(:mailchimp_list_subscribe)
      end
      it "updates mailchimp_subscribed_at column" do
        u = User.first
        mc = u.mailchimp_subscribed_at
        User.first.subscribe_and_welcome
        u.reload
        expect(u.mailchimp_subscribed_at).to be <= Time.zone.now.utc.to_date
      end
    end
  end
end
