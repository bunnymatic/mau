class YoutubeUrlValidator < ActiveModel::EachValidator
  YOUTUBE_URL_REGEX = %r{^((?:https?:)?//)?((?:www|m)\.)?((?:youtube\.com|youtu.be))(/(?:[\w\-]+\?v=|embed/|v/)?)([\w\-]+)(\S+)?$}.freeze

  def validate_each(record, attribute, value)
    # test for presence separately
    return true if value.blank?

    unless valid_url?(value)
      record.errors.add(attribute,
                        options[:message] || 'is not a valid URL. Did you remember including http:// or https:// at the beginning?')
      return
    end

    return if YOUTUBE_URL_REGEX.match?(value)

    record.errors.add(attribute,
                      options[:message] || 'does not look like a Youtube link.')
  end

  private

  def valid_url?(value)
    URI.parse(value).is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end
end
