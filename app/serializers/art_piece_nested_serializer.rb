class ArtPieceNestedSerializer < ArtPieceSerializer
  attributes :id, :image_urls, :artist, :medium, :tags, :favorites_count, :image_files, :year, :dimensions, :filename, :title

  include HtmlHelper

end
