class ArtPieceJsonPresenter

  include HtmlHelper

  attr_reader :art

  def initialize(art_piece)
    @art = art_piece
  end

  def artist
    @artist ||= art.artist
  end

  def attributes
    @attributes ||= art.attributes
  end

  def title
    @title ||= html_encode art.title
  end

  def dimensions
    @dimensions ||= art.dimensions
  end

  def medium
    @medium ||= art.try(:medium).try(:attributes)
  end

  def tags
    @tags ||=
      begin
        return unless art.tags.present?
        tag_attrs = art.tags.map{|t| t.attributes}
        tag_attrs.each {|t| t['name'] = html_encode t['name']}
        tag_attrs
      end
  end

  def artist_name
    @artist_name ||= artist.get_name(true)
  end

  def image_dimensions
    @image_dimensions ||= art.compute_dimensions
  end

  def favorites_count
    @favorites_count ||= Favorite.art_pieces.where(:favoritable_id => art.id).count
    @favorites_count if @favorites_count > 0
  end

  def image_files
    @files ||= art.get_paths
  end

  def to_json
    {'art_piece' => {}.tap do |info|
        info.merge! attributes
        info['tags'] = tags
        info['medium'] = medium
        %w(title dimensions).each do |k|
          info[k] = html_encode(send(k))
        end
        %w(favorites_count image_dimensions image_files artist_name).each do |k|
          info[k] = send(k)
        end
      end
    }
  end
end
