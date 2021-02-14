class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    stripped = value.gsub(/\D/, '')
    return if stripped.length == 11 || (stripped.length == 10 && !stripped.starts_with?('1'))

    record.errors.add attribute, (options[:message] || 'must be 10 or 11 digits')
  end
end
