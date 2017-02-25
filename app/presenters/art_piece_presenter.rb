# frozen_string_literal: true
class ArtPiecePresenter < ViewPresenter
  attr_reader :art_piece
  delegate :id, :year, :photo, :medium, :get_path, :artist, :title, :updated_at, :to_param, to: :art_piece

  def initialize(art_piece)
    @art_piece = art_piece
  end

  def favorites_count
    @favorites_count ||= Favorite.art_pieces.where(favoritable_id: @art_piece.id).count
    @favorites_count if @favorites_count > 0
  end

  def artist_name
    artist.get_name
  end

  def has_medium?
    medium.present?
  end

  def has_tags?
    tags.present?
  end

  def tags
    @tags ||= @art_piece.uniq_tags
  end

  def has_year?
    year.present? and year.to_i > 1899
  end

  def path
    url_helpers.art_piece_path(art_piece)
  end

  def url
    url_helpers.art_piece_url(art_piece)
  end

  alias show_path path
  alias destroy_path path

  def edit_path
    url_helpers.edit_art_piece_path(art_piece)
  end

  def artist_path
    url_helpers.artist_path(artist)
  end
end
