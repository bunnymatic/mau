class ArtistSerializer < MauSerializer
  attributes :full_name, :doing_open_studios, :profile_images, :id, :url, :studio_id, :street_address, :city, :map_url, :firstname, :lastname, :nomdeplume, :slug, :art_pieces, :artist_info

  def art_pieces
    object.art_pieces.map{|a| Hash[[:id].map{|k| [k, a.send(k)]}]}
  end

  def street_address
    address = object.address_hash.parsed.street
  end

  def city
    address = object.address_hash.parsed.city
  end

  def map_url
    object.map_link
  end
end
