# frozen_string_literal: true

class NotInTheFutureValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    return unless value >= Time.zone.today

    record.errors.add attribute, (options[:message] || "can't be in the future")
  end
end
