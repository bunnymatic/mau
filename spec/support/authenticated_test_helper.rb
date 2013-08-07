module AuthenticatedTestHelper
  # Sets the current artist in the session from the artist fixtures.
  def login_as(user)
    @request.session[:user_id] = user ? (user.is_a?(User) ? user.id : users(user).id) : nil
  end


  def authorize_as(artist)
    @request.env["HTTP_AUTHORIZATION"] = artist ? ActionController::HttpAuthentication::Basic.encode_credentials(users(artist).login, 'monkey') : nil
  end
  
end
