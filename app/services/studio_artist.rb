class StudioArtistError < StandardError; end

class StudioArtist
  def initialize(studio, artist)
    raise StudioArtistError, 'artist must be an artist' unless artist.is_a? Artist
    raise StudioArtistError, 'studio must be a studio' unless studio.is_a? Studio

    @studio = studio
    @artist = artist
  end

  def unaffiliate
    if artist_is_in_studio?
      removed = @artist.update(studio: nil)
      artist_roles.where(role: Role.manager).destroy_all
      removed
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
