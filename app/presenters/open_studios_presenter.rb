# frozen_string_literal: true

class OpenStudiosPresenter
  PAGE = 'main_openstudios'

  def packaged_summary
    section = 'summary'
    @packaged_summary ||= CmsDocument.packaged(PAGE, section)
  end

  def summary_data
    @summary_data = editable_content_data(packaged_summary)
  end

  def summary
    packaged_summary[:content]
  end

  def packaged_preview_reception
    section = 'preview_reception'
    @packaged_preview_reception ||= CmsDocument.packaged(PAGE, section)
  end

  def preview_reception_data
    @preview_reception_data ||= editable_content_data(packaged_preview_reception)
  end

  def preview_reception
    packaged_preview_reception[:content]
  end

  def os_participants
    @os_participants ||= OpenStudiosEventService.current.artists.in_the_mission
  end

  def participating_studios
    @participating_studios ||= sort_studios_by_name(os_participants.map(&:studio).compact.uniq)
  end

  def participating_indies
    @participating_indies ||= sort_artists_by_name(os_participants.reject { |a| a.studio || a.address.blank? })
  end

  def sort_studios_by_name(studios)
    studios.compact.uniq.sort(&Studio::SORT_BY_NAME)
  end

  def sort_artists_by_name(artists)
    artists.compact.uniq.sort(&Artist::SORT_BY_LASTNAME)
  end

  private

  def editable_content_data(packaged_data)
    Hash[packaged_data.reject { |k, _v| k == :content }.map { |item| ["data-#{item[0]}", item[1]] }]
  end
end
