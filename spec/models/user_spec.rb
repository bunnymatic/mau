require 'rails_helper'

describe User, elasticsearch: :stub do
  let(:simple_artist) { FactoryBot.build(:artist) }
  let(:maufan) { FactoryBot.create(:fan, :active) }
  let(:artist) { FactoryBot.create(:artist, :with_art, profile_image: 'profile.jpg') }
  let(:art_piece) { artist.art_pieces.first }
  let(:admin) { FactoryBot.create(:artist, :admin, :with_art) }
  let(:manager) { FactoryBot.create(:artist, :manager, :with_studio) }
  let(:editor) { FactoryBot.create(:artist, :editor) }
  let(:managing_editor) { FactoryBot.create(:artist, :manager, :editor) }

  subject(:user) { FactoryBot.build(:user, :active) }

  before do
    freeze_time
  end

  it 'allows unicode characters for name fields' do
    user.nomdeplume = '蕭秋芬'
    user.save!
    expect(user.reload.nomdeplume).to eql '蕭秋芬'
  end

  it 'requires password and password confirmation' do
    user.password = ''
    user.password_confirmation = ''
    user.valid?
    expect(user).to have_at_least(1).error_on(:password_confirmation)
  end

  it { is_expected.to validate_presence_of(:login) }
  it { is_expected.to validate_length_of(:login).is_at_least(5).is_at_most(40) }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_length_of(:email).is_at_least(6).is_at_most(100) }

  it { is_expected.to validate_length_of(:firstname).is_at_most(100) }
  it { is_expected.to validate_length_of(:lastname).is_at_most(100) }

  it 'validates and cleans phone number on validate' do
    user = FactoryBot.build(:user)
    user.phone = '(415) 123 - 4567'
    expect(user).to be_valid
    expect(user.phone).to eq '4151234567'
  end

  context '.login_or_email_finder' do
    let!(:artist) { create :artist, login: 'whatever_yo', email: 'yo_whatever@example.com' }
    it 'finds users by their login' do
      expect(User.login_or_email_finder('whatever_yo')).to eql artist
    end
    it 'finds users by their email' do
      expect(User.login_or_email_finder('yo_whatever@example.com')).to eql artist
    end
    it 'returns nil when there is no match' do
      expect(User.login_or_email_finder('ack')).to be_nil
    end
  end

  context 'unique field constraints' do
    before do
      stub_signup_notification
    end
    it { is_expected.to validate_uniqueness_of(:login).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  context 'make sure our factories work' do
    it 'creates an editor' do
      expect(FactoryBot.create(:user, :editor, :active).editor?).to eq(true)
    end
    it 'creates an admin' do
      expect(FactoryBot.create(:user, :admin, :active).admin?).to eq(true)
    end
  end

  describe '#sortable_name' do
    let(:user1) { FactoryBot.create(:user, :active, firstname: nil, lastname: nil, login: 'zzzzza') }
    let(:user2) { FactoryBot.create(:user, :active, firstname: nil, lastname: nil, login: 'bbbbbb') }
    let(:user3) { FactoryBot.create(:user, :active, firstname: nil, lastname: nil, login: 'aaaaaa') }
    let(:artists) { [user1, user2, user3] }
    let(:sorted_artists) do
      artists.sort_by(&:sortable_name)
    end

    context 'when artists only have a login' do
      it 'should sort the artists by their login name' do
        expect(sorted_artists.first.login).to eql user3.login
        expect(sorted_artists[1].login).to eql user2.login
        expect(sorted_artists.last.login).to eql user1.login
      end
    end

    context 'when the artists last name is punctuation' do
      let(:user1) { FactoryBot.create(:user, :active, firstname: 'RUBYSPAM', lastname: '*', login: 'aaabbb') }
      it 'should sort the artists by their login name' do
        expect(sorted_artists.first.login).to eql user3.login
        expect(sorted_artists[1].login).to eql user2.login
        expect(sorted_artists.last.login).to eql user1.login
      end
    end

    context 'when some artists have empty last names' do
      let(:user1) { FactoryBot.create(:user, :active, firstname: 'bob', lastname: 'kabob', login: 'zzzzza') }
      let(:user2) { FactoryBot.create(:user, :active, firstname: 'Bob', lastname: ' ', login: 'bbbbbb') }
      let(:user3) { FactoryBot.create(:user, :active, firstname: 'faern', lastname: '', login: 'cccccc') }
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
        u = FactoryBot.build(:user, firstname: nil, lastname: nil, nomdeplume: nil)
        expect(u.full_name).to eql u.login
      end
      it 'returns first/last name for full name' do
        u = FactoryBot.build(:user, firstname: 'yo', lastname: 'tHere', nomdeplume: nil)
        expect(u.full_name).to eql [u.firstname, u.lastname].join(' ')
      end
      it 'returns nom de plume if it\'s available' do
        u = FactoryBot.build(:user, firstname: 'yo', lastname: 'tHere', nomdeplume: "I'm So Famous")
        expect(u.full_name).to eql u.nomdeplume
      end
    end
  end
  describe 'new' do
    context 'with a bad email' do
      it "should not allow 'bogus email' for email address" do
        user = FactoryBot.build(:user, email: 'bogus email')
        expect(user).not_to be_valid
        expect(user).to have_at_least(1).error_on(:email)
      end

      it "should not allow '   ' for email" do
        user = FactoryBot.build(:user, email: '  ')
        expect(user).not_to be_valid
        expect(user).to have_at_least(1).error_on(:email)
      end
      it 'should not allow blow@ for email' do
        user = FactoryBot.build(:user, email: 'blow@')
        expect(user).not_to be_valid
        expect(user).to have_at_least(1).error_on(:email)
      end
    end
  end
  describe 'named scope' do
    before do
      create(:user, :active)
      create(:user, :pending)
      create(:user, :suspended)
      create(:user, :deleted)
      create(:user)
    end
    it 'active returns only active users' do
      expect(User.active.pluck(:state)).to be_all('active')
    end
    it 'pending returns only pending users' do
      expect(User.pending.pluck(:state)).to be_all('pending')
    end
    it 'bad_standing returns only suspended or deleted users' do
      expect(User.bad_standing.pluck(:state).compact.uniq).to match_array %w[suspended deleted]
    end
  end

  describe 'get_name' do
    it 'returns nom de plume if defined' do
      user = FactoryBot.build(:user, nomdeplume: 'blurp')
      expect(user.get_name).to eql 'blurp'
    end
    it 'returns first + last if defined' do
      user = FactoryBot.build(:user, nomdeplume: nil)
      expect(user.get_name).to eql([user.firstname, user.lastname].join(' '))
    end
    it 'returns login if nom, and firstname are not defined' do
      user = FactoryBot.build(:user, nomdeplume: '', firstname: '')
      expect(user.get_name).to eql user.login
    end
    it 'returns login if nom, and lastname are not defined' do
      user = FactoryBot.build(:user, nomdeplume: '', lastname: '')
      expect(user.get_name).to eql user.login
    end
  end

  describe 'get_profile_image' do
    context 'when the user has a photo' do
      let(:artist) { build_stubbed(:artist, :with_photo) }
      it 'returns the medium artists profile image' do
        expect(artist.get_profile_image).to match %r{system/artists/photos/(.*)/medium/new-profile.jpg}
      end
      it 'returns the small artists profile image given size = small' do
        expect(artist.get_profile_image(:small)).to match %r{system/artists/photos/(.*)/small/new-profile.jpg}
      end
    end
    context 'when there is no image' do
      it 'returns nil' do
        expect(artist.get_profile_image).to be_nil
      end
    end
  end

  describe 'roles' do
    let!(:roles) do
      FactoryBot.create :role, :admin
      FactoryBot.create :role, :editor
      FactoryBot.create :role, :manager
    end

    it 'without admin role user is not admin' do
      expect(artist).not_to be_admin
    end
    it 'without editor role user is not editor' do
      expect(artist).not_to be_editor
    end
    it 'with admin role, user is admin' do
      expect(admin).to be_admin
    end
    it 'with editor role, user is editor' do
      expect(editor).to be_editor
    end
    it 'with editor and manager role, user is editor and manager but not admin' do
      expect(managing_editor).to be_editor
      expect(managing_editor).to be_manager
      expect(managing_editor).not_to be_admin
    end
    it 'with admin role, user is editor and manager and admin' do
      expect(admin).to be_editor
      expect(admin).to be_manager
      expect(admin).to be_admin
    end
    it 'does not save multiple roles of the same type' do
      expect do
        manager.roles << Role.where(role: :manager).first
      end.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'address' do
    it 'responds to address' do
      expect(simple_artist).to respond_to :address
    end
    it 'responds to full address' do
      expect(simple_artist).to respond_to :full_address
    end
    it 'returns nothing' do
      expect(simple_artist.address).not_to be_present
    end
  end
  describe 'unavailable methods' do
    it "doesn't reply to old artists attributes" do
      %i[lat lng bio street city zip].each do |method|
        expect(maufan).not_to respond_to method
      end
    end
  end

  describe 'forgot password methods' do
    context 'artfan' do
      before do
        travel_to(1.hour.since)
      end
      it 'create_reset_code creates a reset code' do
        ActiveJob::Base.queue_adapter = :test
        expect(maufan.reset_code).to be_nil
        expect do
          maufan.create_reset_code
          expect(maufan.reset_code).not_to be_nil
        end.to have_enqueued_job.on_queue('mailers')
      end
    end
    context 'artist' do
      it 'create_reset_code creates a reset code' do
        expect(artist.reset_code).to be_nil
        artist.create_reset_code
        expect(artist.reset_code).not_to be_nil
      end
    end
  end

  describe 'field cleaner' do
    let(:simple_artist) { build :artist, firstname: '  first  ', lastname: ' _ _ _ ', nomdeplume: ' mi nom ' }
    it 'cleans firstname, lastname and nomdeplume fields of whitespace before save' do
      simple_artist.valid?
      expect(simple_artist.firstname).to eql 'first'
    end
  end
end
