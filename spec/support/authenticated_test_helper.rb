module AuthenticatedTestHelper
  # Sets the current artist in the session from the artist factories
  def login_as(user, session_stubs = nil)
    logout
    session_stubs ||= { record: true }
    u = user.is_a?(User) ? user : FactoryBot.create(:user, :active, user)
    allow(UserSession).to receive(:find).and_return(user_session(current_user(u), session_stubs))
    @logged_in_user = u
    @logged_in_artist = u if u.is_a? Artist
    u
  end

  def current_user(user = nil)
    @current_user = user || FactoryBot.create(:user)
  end

  def user_session(user, stubs = {})
    @current_user_session = double(UserSession, { user: }.merge(stubs))
  end

  def logout
    @current_user_session = nil
    @current_user = nil
    @logged_in_user = nil
    @logged_in_artist = nil
  end
end

RSpec.configure do |config|
  config.include AuthenticatedTestHelper, type: :controller
end
