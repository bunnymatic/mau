# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # test for presence separately
    return true if value.blank?

    valid = begin
      URI.parse(value).is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
    record.errors.add(attribute, options[:message] || 'is not a valid URL') unless valid
  end
end
