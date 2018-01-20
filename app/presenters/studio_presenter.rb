# frozen_string_literal: true

class StudioPresenter < ViewPresenter
  include OpenStudiosEventShim

  attr_reader :studio
  delegate :slug, :phone, :phone?, :map_link,
           :city, :street, :cross_street, :url, :url?, :to_param, to: :studio

  def initialize(studio)
    @studio = studio
  end

  def name
    studio.try(:name)
  end

  def search_name
    (name || '').downcase
  end

  def phone?
    phone.present?
  end

  def formatted_phone
    phone.gsub(/(\d{3})(\d{3})(\d{4})/, '(\\1) \\2-\\3')
  end

  def page_title
    @page_title ||= PageInfoService.title("Studio: #{name}")
  end

  def profile_image?
    @studio.get_profile_image(:small).present?
  end

  def image(size = 'small')
    @studio.get_profile_image(size) || '/images/default-studio.png'
  end

  def street_with_cross
    [@studio.street, ("(@ #{studio.cross_street})" if @studio.cross_street?)].compact.join(' ')
  end

  def artists_count_label
    @artists_count_label ||=
      artists? ? "#{artists.count} artist".pluralize(artists.count) : ''
  end

  def open_studios_artists_count_label
    @open_studios_count_label ||=
      begin
        if open_studios_artists? && current_open_studios
          "#{open_studios_artists.count} artist".pluralize(open_studios_artists.count) +
            " in #{current_open_studios.title}"
        else
          ''
        end
      end
  end

  def open_studios_artists
    artists.open_studios_participants
  end

  def artists_with_art?
    artists_with_art.present?
  end

  def artists_with_art
    @artists_with_art ||=
      begin
        artists.select { |a| a.art_pieces.present? }.map { |artist| ArtistPresenter.new(artist) }
      end
  end

  def artists?
    artists.count.positive?
  end

  def open_studios_artists?
    open_studios_artists.count.positive?
  end

  def artists_without_art?
    artists_without_art.present?
  end

  def artists_without_art
    @artists_without_art ||= artists.select { |a| a.art_pieces.empty? }
  end

  def artists
    @artists ||= @studio.artists.active
  end

  def indy?
    @studio.id.zero?
  end

  def website
    url.gsub('http://', '')
  end

  def studio_path
    url_helpers.studio_path(@studio)
  end

  def current_open_studios
    @current_open_studios ||= OpenStudiosEventService.current
  end
end
