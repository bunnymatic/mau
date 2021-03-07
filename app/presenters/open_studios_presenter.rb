class OpenStudiosPresenter
  PAGE = 'main_openstudios'.freeze

  delegate :promote?, to: :current_os

  def initialize(current_user)
    @user = current_user
  end

  def packaged_summary
    section = 'summary'
    @packaged_summary ||= CmsDocument.packaged(PAGE, section)
  end

  def packaged_preview_reception
    section = 'preview_reception'
    @packaged_preview_reception ||= CmsDocument.packaged(PAGE, section)
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

  def register_for_open_studio_button_text
    if @user&.artist? && @user&.doing_open_studios?
      'Artist OS Info'
    else
      'Artist Registration'
    end
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
