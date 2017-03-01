# frozen_string_literal: true
# This presenter adds helpful display/view related methods
# to make it easy to draw artist data on a page

class ArtistPresenter < UserPresenter
  include ApplicationHelper

  ALLOWED_LINKS = User.stored_attributes[:links]

  attr_accessor :model

  delegate :doing_open_studios?, :os_participation, :studio, :studio_id,
           :artist_info, :at_art_piece_limit?, :studionumber,
           :max_pieces, :pending?, :active?,
           to: :artist, allow_nil: true

  def artist?
    artist && model.is_a?(Artist)
  end

  def artist
    model
  end

  def name
    model.get_name
  end

  def media?
    media.present?
  end

  def get_share_link(urlsafe = false, options = {})
    link = artist_url(model, options)
    urlsafe ? CGI.escape(link) : link
  end

  def primary_medium
    _primary_medium.try(:name).presence.to_s
  end

  def primary_medium_hashtag
    (_primary_medium ? MediumPresenter.new(_primary_medium).hashtag : '')
  end

  def _primary_medium
    return @_primary_medium if @_primary_medium
    media = art_pieces.map(&:medium).compact
    medium = StatsCalculator.histogram(media).map(&:first).first
    @_primary_medium = medium
  end

  def media
    @media ||= art_pieces.map(&:medium).compact.uniq
  end

  def tags
    @tags ||= art_pieces.map(&:tags).flatten.compact.uniq
  end

  def media_and_tags
    (media + tags).map(&:name).flatten.compact.uniq
  end

  def bio?
    !model.bio.blank?
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
    @studio_name ||= studio.name
  end

  def studio_number
    number = artist.artist_info.try(:studionumber)
    number.present? ? ('#' + number) : ''
  end

  delegate :address?, to: :model

  delegate :in_the_mission?, to: :model

  def map_url
    if model.studio
      model.studio.map_link
    else
      model.map_link
    end
  end

  def map_info
    content_tag('div', map_info_contents, class: 'map__info-window')
  end

  def representative_piece
    @representative_piece ||=
      begin
        r = artist.representative_piece
        ArtPiecePresenter.new(r) if r.is_a?(ArtPiece)
      end
  end

  def representative_piece_title
    representative_piece.try(:title)
  end

  def representative_piece_url
    representative_piece.try(:photo).try(:url, :original)
  end

  def representative_piece_medium
    representative_piece.medium.try(:name)
  end

  def representative_piece_tags
    (representative_piece.tags || []).map(&:name)
  end

  def map_info_contents
    thumb = content_tag('div', linked_thumb, class: 'map__info-window-art')
    safe_join([thumb, map_info_name_address].compact)
  end

  def map_info_name_address
    content_tag 'div', class: 'map__info-window-text' do
      name = content_tag 'a', get_name, href: url_helpers.artist_path(model)
      html = [name]
      street = address.street
      if artist.studio
        html << content_tag('div', artist.try(:studio).try(:name), class: 'studio')
        html << content_tag('div', street)
      else
        html << content_tag('div', street)
      end
      safe_join(html)
    end
  end

  def bio_html
    @bio_html ||= begin
                    if bio.present?
                      MarkdownService.markdown(bio, :filter_html)
                    else
                      content_tag('h4', "No artist's statement")
                    end
                  end
  end

  def facebook
    model.links[:facebook]
  end

  def twitter
    model.links[:twitter]
  end

  def blog
    model.links[:blog]
  end

  def instagram
    model.links[:instagram]
  end

  def myspace
    model.links[:myspace]
  end

  def pinterest
    model.links[:pinterest]
  end

  def flickr
    model.links[:flickr]
  end

  def artspan
    model.links[:artspan]
  end

  def self.keyed_links
    (User.stored_attributes[:links] || []).select { |attr| ALLOWED_LINKS.include? attr }
  end

  private

  def map_thumb
    @representative_thumb ||= representative_piece.path('thumb')
  end

  def map_thumb_image
    @representative_thumb_image ||= content_tag('div', '', class: 'thumb', style: background_image_style(map_thumb))
  end

  def linked_thumb
    return unless representative_piece
    @linked_thumb ||= content_tag('a', map_thumb_image, href: url_helpers.artist_path(model))
  end
end
