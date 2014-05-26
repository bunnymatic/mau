module AuthenticatedTestHelper

  # Sets the current artist in the session from the artist fixtures.
  def login_as(user, session_stubs = nil)
    session_stubs ||= {}
    u = user ? (user.is_a?(User) ? user : users(user)) : nil
    allow(UserSession).to receive(:find).and_return(user_session(current_user(u), session_stubs))
    u
  end

  def current_user(user = nil)
    @current_user ||= (user || FactoryGirl.create(:user))
  end

  def user_session(user, stubs = {})
    @current_user_session ||= double(UserSession, {:user => user}.merge(stubs))
  end

  def logout
    @current_user_session = nil
  end

end

