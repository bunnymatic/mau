json.array! @results do |art|
  json.title art.safe_title
  json.medium art.medium.try(:name)
  json.artist_name art.artist.get_name(true)
  json.image art.get_path(:small)
  json.link_to art_piece_path(art)
end
