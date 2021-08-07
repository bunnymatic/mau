class OpenStudiosEventPresenter < ViewPresenter
  attr_reader :model

  delegate :end_time,
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
    DateRangeHelpers.date_range(model.start_date, model.end_date, separator: separator)
  end

  def time_range
    DateRangeHelpers.time_range(model.start_time, model.end_time)
  end

  def special_event_date_range_with_year
    return unless model.special_event_start_date && model.special_event_end_date

    DateRangeHelpers.date_range_with_year(model.special_event_start_date,
                                          model.special_event_end_date)
  end

  def special_event_date_range(separator: '-')
    return unless model.special_event_start_date && model.special_event_end_date

    DateRangeHelpers.date_range(model.special_event_start_date, model.special_event_end_date,
                                separator: separator)
  end

  def special_event_time_range
    return unless model.special_event_start_date && model.special_event_end_date

    DateRangeHelpers.time_range(model.special_event_start_time,
                                model.special_event_end_time)
  end

  def for_display(reverse: false)
    if available?
      model.for_display(reverse: reverse)
    else
      OpenStudiosEventService.for_display(current_open_studios_key, reverse: reverse)
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
      asset_pack_path('media/images/mau-nextos.png')
    end
  end

  def available?
    !@model.nil?
  end

  def with_special_event?
    !!(@model.special_event_start_date && @model.special_event_end_date)
  end

  def start_date
    model.start_date.strftime('%b %d, %Y')
  end

  def end_date
    model.end_date.strftime('%b %d, %Y')
  end
end
