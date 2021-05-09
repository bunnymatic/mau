class ApplicationEventQuery
  include ActiveModel::Model

  attr_reader :since, :number_of_records

  validate :only_date_or_limit_is_set
  validates :since, not_in_the_future: true
  validates :number_of_records, numericality: { greater_than: 0, only_integer: true }, if: -> { !since? }

  ALLOWED_NUM_EVENTS = [10, 100, 200, 400, 800, 1600].freeze
  DEFAULT_NUM_EVENTS = ALLOWED_NUM_EVENTS[0]

  def initialize(*args)
    super
    @number_of_records = 100 if args.empty?
  end

  def since=(val)
    return if val.blank?

    @since = (if val.respond_to?(:strftime)
                val
              else
                Time.zone.parse(val).to_date
              end)
  end

  def number_of_records=(val)
    @number_of_records = val.to_i if val
  end

  def number_of_records?
    number_of_records.presence.to_i.positive?
  end

  def since?
    @since.present?
  end

  def to_s
    return 'invalid' unless valid?
    return "Since #{since}" if since?

    "#{number_of_records} records"
  end

  private

  def only_date_or_limit_is_set
    return unless number_of_records? && since?

    errors.add(:base, 'Only since or number of records should be set')
  end
end
