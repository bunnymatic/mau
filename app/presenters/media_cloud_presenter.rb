# frozen_string_literal: true

class MediaCloudPresenter < ViewPresenter
  include Enumerable

  def initialize(selected, mode)
    @media = MediaService.media_sorted_by_frequency
    @selected = selected
    @mode = mode
  end

  def current_medium?(medium)
    @selected == medium
  end

  def medium_path(medium)
    url_helpers.medium_path(medium, m: @mode)
  end

  def each(&block)
    @media.each(&block)
  end
end
