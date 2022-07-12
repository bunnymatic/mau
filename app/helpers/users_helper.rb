module UsersHelper
  def pretty_phone_number(phone)
    return unless phone

    matches = phone.match(/^1?\(?([0-9]{3})\)?[-.●]?([0-9]{3})[-.●]?([0-9]{4})$/)
    return unless matches

    matches.to_a[1..].join('.')
  end
end
