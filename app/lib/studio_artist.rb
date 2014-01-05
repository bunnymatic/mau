class StudioArtistError < StandardError; end

class StudioArtist

  def initialize(studio, artist)
    raise StudioArtistError.new 'artist must be an artist' unless artist.is_a? Artist
    raise StudioArtistError.new 'studio must be a studio' unless studio.is_a? Studio
    @studio = studio
    @artist = artist
  end

  def unaffiliate
    @artist.update_attribute(:studio_id, 0)
    artist_roles.select(&:is_manager_role?).each(&:destroy)
  end

  private
  def manager_role
    @manager_role ||= Role.manager
  end

  def artist_roles
    @artist_roles ||= @artist.roles_users
  end


end
