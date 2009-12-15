module AuthenticatedTestHelper
  # Sets the current artist in the session from the artist fixtures.
  def login_as(artist)
    @request.session[:artist_id] = artist ? (artist.is_a?(Artist) ? artist.id : artists(artist).id) : nil
  end

  def authorize_as(artist)
    @request.env["HTTP_AUTHORIZATION"] = artist ? ActionController::HttpAuthentication::Basic.encode_credentials(artists(artist).login, 'monkey') : nil
  end
  
end
