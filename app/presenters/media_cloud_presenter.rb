# frozen_string_literal: true

class MediaCloudPresenter < ViewPresenter
  include Enumerable

  delegate :medium_path, to: :url_helpers

  def initialize(selected)
    super()
    @media = MediaService.media_sorted_by_frequency
    @selected = selected
  end

  def current_medium?(medium)
    @selected == medium
  end

  def each(&block)
    @media.each(&block)
  end
end
