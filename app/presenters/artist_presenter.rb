# This presenter adds helpful display/view related methods
# to make it easy to draw artist data on a page

class ArtistPresenter < UserPresenter
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  ALLOWED_LINKS = User.stored_attributes[:links]

  attr_accessor :model

  delegate :!=,
           :==,
           :active?,
           :address,
           :artist?,
           :artist_info,
           :at_art_piece_limit?,
           :current_open_studios_participant,
           :deleted?,
           :doing_open_studios?,
           :in_the_mission?,
           :lat,
           :lng,
           :max_pieces,
           :os_participation,
           :pending?,
           :phone,
           :slug,
           :sortable_name,
           :studio,
           :studio_id,
           :studionumber,
           :suspended?,
           :updated_at,
           :to_model,
           to: :artist,
           allow_nil: true
  delegate(*ALLOWED_LINKS, to: :artist, allow_nil: true)
  delegate :broadcasting?, to: :open_studios_info, allow_nil: true

  def artist
    model
  end

  def name
    model.get_name
  end

  def media?
    media.present?
  end

  def show_url
    artist_url(model)
  end

  def primary_medium
    _primary_medium.try(:name).presence.to_s
  end

  def primary_medium_hashtag
    (_primary_medium ? _primary_medium.hashtag : '')
  end

  def _primary_medium
    return @_primary_medium if @_primary_medium

    media = art_pieces.filter_map(&:medium)
    medium = StatsCalculator.histogram(media).map(&:first).first
    @_primary_medium = medium
  end

  def media
    @media ||= art_pieces.filter_map(&:medium).uniq
  end

  def tags
    @tags ||= art_pieces.map(&:tags).flatten.compact.uniq
  end

  def media_and_tags
    (media + tags).map(&:name).flatten.compact.uniq
  end

  def bio?
    model.bio.present?
  end

  def art?
    artist? && art_pieces.present?
  end

  def art_pieces
    return [] unless artist?

    @art_pieces ||=
      begin
        num = (artist.max_pieces || 20) - 1
        artist.art_pieces.select(&:persisted?)[0..num].compact.map { |piece| ArtPiecePresenter.new(piece) }
      end
  end

  def favorites_count
    @favorites_count ||= who_favorites_me.count
    @favorites_count if @favorites_count.positive?
  end

  def studio_name
    @studio_name ||= studio&.name
  end

  def studio_number
    number = artist.artist_info.try(:studionumber)
    number.present? ? "##{number}" : ''
  end

  def map_url
    @map_url ||= model.map_link
  end

  def map_info
    tag.div(map_info_contents, class: 'map__info-window')
  end

  def representative_piece
    @representative_piece ||=
      begin
        r = artist.representative_piece
        ArtPiecePresenter.new(r) if r
      end
  end

  def representative_piece_title
    representative_piece.try(:title)
  end

  def representative_piece_url
    representative_piece.try(:image, :original)
  end

  def representative_piece_medium
    representative_piece.medium.try(:name)
  end

  def representative_piece_tags
    (representative_piece.tags || []).map(&:name)
  end

  def map_info_contents
    thumb = tag.div(linked_thumb, class: 'map__info-window-art')
    safe_join([thumb, map_info_name_address].compact)
  end

  def map_info_name_address
    tag.div(class: 'map__info-window-text') do
      name = tag.a(get_name, href: url_helpers.artist_path(model))
      html = [name]
      html << tag.div(artist.try(:studio).try(:name), class: 'studio') if artist.studio
      html << tag.div(address.street)
      safe_join(html)
    end
  end

  def bio_html
    @bio_html ||= bio.present? ? MarkdownService.markdown(bio, :filter_html) : tag.h4("No artist's statement")
  end

  def self.keyed_links
    ALLOWED_LINKS
  end

  def open_studios_info
    return unless artist.current_open_studios_participant

    @open_studios_info ||=
      OpenStudiosParticipantPresenter.new(artist.current_open_studios_participant)
  end

  def phone_for_display
    number_to_phone(artist.phone)
  end

  def last_updated_profile
    Time.use_zone(Conf.event_time_zone) do
      last_updated_at.to_fs(:admin)
    end
  end

  def last_updated_at
    if open_studios_info
      [open_studios_info.updated_at, super].max
    else
      super
    end
  end

  def keyed_links
    (@model.links || {}).keep_if { |k, v| (ALLOWED_LINKS.include? k.to_sym) && v.present? }
  end

  private

  def map_thumb
    @map_thumb ||= representative_piece.image('thumb')
  end

  def map_thumb_image
    @map_thumb_image ||= tag.div('', class: 'thumb', style: background_image_style(map_thumb))
  end

  def linked_thumb
    return unless representative_piece

    @linked_thumb ||= tag.a(map_thumb_image, href: url_helpers.artist_path(model))
  end
end
