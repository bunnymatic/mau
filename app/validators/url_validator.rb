class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # test for presence separately
    return true if value.blank?

    valid = begin
      URI.parse(value).is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
    return if valid

    record.errors.add(attribute,
                      options[:message] || 'is not a valid URL. Did you remember including http:// or https:// at the beginning?')
  end
end
