module AuthenticatedTestHelper
  # Sets the current artist in the session from the artist fixtures.
  def login_as(user)
    u = user ? (user.is_a?(User) ? user : users(user)) : nil
    @request.session[:user_id] = u.id
    @request.session[:auth_token] = u
  end

end
