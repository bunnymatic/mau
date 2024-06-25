class OpenStudiosEventPresenter < ViewPresenter
  attr_reader :model

  delegate :activated_at,
           :artists,
           :deactivated_at,
           :end_time,
           :key,
           :logo,
           :logo?,
           :promote?,
           :special_event_end_date,
           :special_event_end_time,
           :special_event_start_date,
           :special_event_start_time,
           :special_event_time_slots,
           :start_date,
           :start_time,
           :to_param,
           :year,
           to: :model

  include OpenStudiosEventShim

  class DateRangeHelpers
    class << self
      def date_range_with_year(start_date, end_date)
        "#{date_range(start_date, end_date)} #{start_date.year}"
      end

      def date_range(start_date, end_date, separator: '-')
        return start_date.strftime('%b %-d') if same_day(start_date, end_date)

        if same_month(start_date, end_date)
          "#{start_date.strftime('%b')} #{start_date.strftime('%-d')}#{separator}#{end_date.strftime('%-d')}"
        else
          start_date.strftime('%b %-d') + separator + end_date.strftime('%b %-d')
        end
      end

      def time_range(start_time, end_time)
        "#{start_time} &mdash; #{end_time}".html_safe
      end

      def same_month(start_date, end_date)
        start_date.month == end_date.month
      end

      def same_day(start_date, end_date)
        start_date.day == end_date.day
      end
    end
  end

  def initialize(os_event)
    super()
    @model = os_event
  end

  def empty?
    !@model
  end

  def ==(other)
    return @model.id == other.model.id if other.is_a? self.class
    return @model.id == other.id if other.is_a? OpenStudiosEvent

    false
  end

  def num_participants
    model.open_studios_participants.count
  end

  def title
    available? && @model.title.present? ? @model.title : 'Open Studios'
  end

  def link_text
    "#{date_range} #{model.start_date.strftime('%Y')}"
  end

  def date_range_with_year
    DateRangeHelpers.date_range_with_year(model.start_date, model.end_date)
  end

  def date_range(separator: '-')
    DateRangeHelpers.date_range(model.start_date, model.end_date, separator:)
  end

  def time_range
    DateRangeHelpers.time_range(model.start_time, model.end_time)
  end

  def special_event_date_range_with_year
    return unless with_special_event?

    DateRangeHelpers.date_range_with_year(model.special_event_start_date,
                                          model.special_event_end_date)
  end

  def special_event_date_range(separator: '-')
    return unless with_special_event?

    DateRangeHelpers.date_range(model.special_event_start_date,
                                model.special_event_end_date,
                                separator:)
  end

  def special_event_time_range
    return unless with_special_event?

    DateRangeHelpers.time_range(model.special_event_start_time,
                                model.special_event_end_time)
  end

  def activation_date_range
    return unless with_activation_dates?

    DateRangeHelpers.date_range(model.activated_at, model.deactivated_at)
  end

  def for_display(month_first: false)
    if available?
      model.for_display(month_first:)
    else
      OpenStudiosEventService.for_display(current_open_studios_key, month_first:)
    end
  end

  def time_range_for_display
    return '' unless available?

    [model.start_time, model.end_time].join('-')
  end

  def display_logo
    if available? && logo?
      logo.url(:square)
    else
      vite_asset_path('entrypoints/images/mau-nextos.png')
    end
  end

  def available?
    !@model.nil?
  end

  def with_special_event?
    !!(@model.special_event_start_date && @model.special_event_end_date)
  end

  def active?
    # currently default to always active if activation dates haven't been specified for
    # backwards compatibility.  If activated_at/deactivated_at become required, this check can
    # go away
    return true unless @model.activated_at && @model.deactivated_at

    Time.zone.now.to_date.between?(@model.activated_at, @model.deactivated_at)
  end

  def with_activation_dates?
    !!(@model.activated_at && @model.deactivated_at)
  end

  def start_date
    model.start_date.strftime('%b %d, %Y')
  end

  def end_date
    model.end_date.strftime('%b %d, %Y')
  end

  def banner_image_url
    model&.banner_image&.url
  end
end
