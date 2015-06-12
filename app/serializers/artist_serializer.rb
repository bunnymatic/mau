class ArtistSerializer < ActiveModel::Serializer
  attributes :full_name, :doing_open_studios, :profile_images
end
