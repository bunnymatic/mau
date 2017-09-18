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

  def link_text
    date_range + ' ' + model.start_date.strftime('%Y')
  end

  def date_range
    same_month = model.start_date.month == model.end_date.month
    same_day = model.start_date.day == model.end_date.day
    return model.start_date.strftime('%b %d') if same_day

    if same_month
      [
        model.start_date.strftime('%b'),
        model.start_date.strftime('%d') + '-' + model.end_date.strftime('%d')
      ].join(' ')
    else
      model.start_date.strftime('%b %d') + '-' + model.end_date.strftime('%b %d')
    end
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
