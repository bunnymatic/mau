# frozen_string_literal: true

class OpenStudiosEventPresenter < ViewPresenter
  attr_reader :model

  delegate :start_date, :start_time, :end_time, :year, :key, :logo, :logo?, :to_param, to: :model

  include OpenStudiosEventShim

  def initialize(os_event)
    @model = os_event
  end

  def num_participants
    model.open_studios_participants.count
  end

  def time_range
    (model.start_time + ' &mdash; ' + model.end_time).html_safe
  end

  def title
    available? && @model.title.present? ? @model.title : 'Open Studios'
  end

  def link_text
    date_range + ' ' + model.start_date.strftime('%Y')
  end

  def date_range_with_year
    date_range + ' ' + year.to_s
  end

  def date_range(separator: '-')
    return model.start_date.strftime('%b %-d') if same_day

    if same_month
      model.start_date.strftime('%b') +
        ' ' +
        model.start_date.strftime('%-d') + separator + model.end_date.strftime('%-d')
    else
      model.start_date.strftime('%b %-d') + separator + model.end_date.strftime('%b %-d')
    end
  end

  def same_month
    @same_month ||= model.start_date.month == model.end_date.month
  end

  def same_day
    @same_day ||= model.start_date.day == model.end_date.day
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

  def year
    model.start_date.year
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
