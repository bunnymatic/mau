class ArtPiecePresenter < ViewPresenter
  include ActionView::Helpers::NumberHelper
  attr_reader :model

  delegate :id, :year, :photo, :medium, :artist, :title, :dimensions, :updated_at, :image_paths, :to_param, to: :model

  def initialize(model)
    super()
    @model = model
  end

  def favorites_count
    @favorites_count ||= Favorite.art_pieces.where(favoritable_id: model.id).count
    @favorites_count if @favorites_count.positive?
  end

  def artist_name
    artist.get_name
  end

  def medium?
    medium.present?
  end

  def tags?
    tags.present?
  end

  def tags
    @tags ||= model.uniq_tags
  end

  def year?
    year.present? && year.to_i > 1899
  end

  def path(size = :medium)
    model.photo(size) if model.photo?
  end

  def show_path
    url_helpers.art_piece_path(model)
  end

  def url
    url_helpers.art_piece_url(model)
  end

  alias destroy_path show_path

  def edit_path
    url_helpers.edit_art_piece_path(model)
  end

  def artist_path
    url_helpers.artist_path(artist)
  end

  def sold?
    !!model.sold_at
  end

  def price?
    model.price.present?
  end

  def price
    number_to_currency(model.price)
  end
end
