class ArtistSerializer < MauSerializer
  attributes :art_pieces,
             :artist_info,
             :doing_open_studios,
             :firstname,
             :full_name,
             :lastname,
             :nomdeplume,
             :profile_images,
             :slug,
             :studio_id

  INDEX_WITH_ID = %i[id].freeze
  attribute :art_pieces do |object|
    object.art_pieces.map { |a| INDEX_WITH_ID.index_with { |k| a.send(k) } }
  end

  attribute :url, &:website

  attribute :link do |object|
    Rails.application.routes.url_helpers.artist_path(object)
  end

  attribute :street_address do |object|
    object.address.street
  end

  attribute :city do |object|
    object.address.city
  end

  attribute :map_url, &:map_link
end
