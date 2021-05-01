class BaseOpenStudiosPresenter < ViewPresenter
  delegate :promote?, to: :current_os

  def initialize(page, current_user)
    super()
    @user = current_user
    @page = page
  end

  def packaged_summary
    section = 'summary'
    @packaged_summary ||= CmsDocument.packaged(@page, section)
  end

  def packaged_preview_reception
    section = 'preview_reception'
    @packaged_preview_reception ||= CmsDocument.packaged(@page, section)
  end

  def participating_studios
    @participating_studios ||= sort_studios_by_name(os_participants.map(&:studio))
  end

  def participating_indies
    @participating_indies ||= sort_artists_by_name(os_participants.reject { |a| a.studio || a.address.blank? })
  end

  def participating_artists
    @participating_artists ||= sort_artists_by_name(os_participants)
  end

  def link_to_artist(artist)
    link =  FeatureFlags.virtual_open_studios? ? artist_url(artist, { subdomain: Conf.subdomain }) : artist_path(artist)
    options = FeatureFlags.virtual_open_studios? ? { target: '_blank' } : {}
    link_to(artist.get_name, link, options)
  end

  def register_for_open_studio_button_text
    'Artist Registration'
  end

  private

  def sort_studios_by_name(studios)
    studios.compact.uniq.sort(&Studio::SORT_BY_NAME)
  end

  def sort_artists_by_name(artists)
    artists.compact.uniq.sort(&Artist::SORT_BY_LASTNAME)
  end

  def current_os
    @current_os ||= OpenStudiosEventService.current
  end

  def os_participants
    @os_participants ||= current_os.artists
  end
end
