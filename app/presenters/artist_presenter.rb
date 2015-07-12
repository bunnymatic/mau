# This presenter adds helpful display/view related methods
# to make it easy to draw artist data on a page

class ArtistPresenter < UserPresenter

  attr_accessor :model

  delegate :doing_open_studios?, :os_participation, :studio, :studio_id,
           :artist_info, :at_art_piece_limit?,:get_share_link,
           :max_pieces,
           to: :artist, allow_nil: true

  def artist
    model
  end

  def has_media?
    media.present?
  end

  def media
    @media ||= art_pieces.map(&:medium).compact.uniq
  end

  def has_bio?
    model.try(:bio) and !model.bio.empty?
  end

  def has_art?
    artist && art_pieces.present?
  end

  def art_pieces
    @art_pieces ||=
      begin
        num = artist.max_pieces - 1
        artist.art_pieces.select(&:persisted?)[0..num].compact.map{|piece| ArtPiecePresenter.new(piece)}
      end
  end

  def favorites_count
    @favorites_count ||= who_favorites_me.count
    @favorites_count if @favorites_count > 0
  end

  def studio_name
    @studio_name ||= studio.name
  end

  def studio_number
    number = artist.artist_info.try(:studionumber)
    number.present? ? ('#' + number) : ''
  end

  def has_address?
    model.has_address?
  end

  def in_the_mission?
    model.in_the_mission?
  end

  def map_url
    if model.studio
      model.studio.map_link
    else
      model.map_link
    end
  end

  def get_map_info
    content_tag('div', map_info_contents, class: 'map__info-window')
  end

  def representative_piece
    @representative_piece ||=
      begin
        r = artist.representative_piece
        ArtPiecePresenter.new(r) if r.is_a?(ArtPiece)
      end
  end

  def map_info_contents
    thumb = content_tag('div', linked_thumb, class: 'map__info-window-art')
    [thumb, map_info_name_address].compact.join.html_safe
  end

  def map_info_name_address
    content_tag 'div', class: 'map__info-window-text' do
      name = content_tag 'a', get_name, href: url_helpers.artist_path(model)
      html = [name]
      street = address_hash.try(:parsed).try(:street)
      if artist.studio
        html << content_tag('div', artist.try(:studio).try(:name), class: 'studio')
        html << content_tag('div', street)
      else
        html << content_tag('div', street)
      end
      html.map(&:html_safe).join.html_safe
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

  private

  def map_thumb
    @representative_thumb ||= representative_piece.get_path('thumb')
  end

  def map_thumb_image
    @representative_thumb_image ||= content_tag('div', '', class: 'thumb', style: "background-image: url(#{map_thumb});")
  end

  def linked_thumb
    if representative_piece
      @linked_thumb ||= content_tag('a', map_thumb_image, href: url_helpers.artist_path(model))
    end
  end

  def self.keyed_links
    [ [:url, 'Website', :u_website],
      [:instagram, 'Instagram', :u_instagram],
      [:facebook, 'Facebook', :u_facebook],
      [:twitter, 'Twitter', :u_twitter],
      [:pinterest, 'Pinterest', :u_pinterest],
      [:flickr, 'Flickr', :u_flickr],
      [:blog, 'Blog', :u_blog],
      [:myspace, 'MySpace', :u_myspace]].freeze
  end

end
