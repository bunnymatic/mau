class StudioArtistError < StandardError; end

class StudioArtist

  def initialize(studio, artist)
    raise StudioArtistError.new 'artist must be an artist' unless artist.is_a? Artist
    raise StudioArtistError.new 'studio must be a studio' unless studio.is_a? Studio
    @studio = studio
    @artist = artist
  end

  def unaffiliate
    puts "artist_roles.count", artist_roles.count
    if artist_is_in_studio?
      @artist.update_attribute(:studio_id, nil)
      artist_roles.select(&:is_manager_role?).each(&:destroy)
    else
      false
    end
  end

  private
  def artist_is_in_studio?
    @artist.studio == @studio
  end

  def artist_roles
    @artist_roles ||= @artist.roles_users
  end

end
