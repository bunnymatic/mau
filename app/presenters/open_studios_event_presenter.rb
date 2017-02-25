# frozen_string_literal: true
class OpenStudiosEventPresenter < ViewPresenter
  attr_reader :model

  delegate :key, :logo, :logo?, :to_param, to: :model

  include OpenStudiosEventShim

  def initialize(os_event)
    @model = os_event
  end

  def title
    available? && @model.title.present? ? @model.title : 'Open Studios'
  end

  def for_display
    if available?
      model.for_display
    else
      OpenStudiosEventService.for_display(current_open_studios_key)
    end
  end

  def display_logo
    if available? && logo?
      logo.url(:square)
    else
      image_path('mau-nextos.png')
    end
  end

  def available?
    !@model.nil?
  end

  def start_date
    model.start_date.strftime('%b %d, %Y')
  end

  def end_date
    model.end_date.strftime('%b %d, %Y')
  end
end
