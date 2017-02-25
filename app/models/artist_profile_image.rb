# frozen_string_literal: true
class ArtistProfileImage < ProfileImage
  def self.get_path(artist, size = 'medium')
    if artist.photo?
      return photo(size)
    else
      # get path for image of size
      # size should be either "thumb","medium"
      if artist && artist.profile_image.present?
        dir = '/artistdata/' + artist.id.to_s + '/profile/'
        fname = File.basename(artist.profile_image)
        ImageFile.get_path(dir, size.to_s, fname)
      end
    end
  end
end
