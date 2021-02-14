module UsersHelper
  def user_signup_select_options(user, type)
    user.password = user.password_confirmation = nil
    entries = [['<select your account type>', ''],
               ['Mission Art Fan', :MauFan],
               ['Mission Artist', :Artist]]
    options = {
      disabled: [entries.first.first],
      selected: [type.presence || entries.first.first],
    }
    options_for_select(entries, options)
  end

  def pretty_phone_number(phone)
    return unless phone

    matches = phone.match(/^1?\(?([0-9]{3})\)?[-.●]?([0-9]{3})[-.●]?([0-9]{4})$/)
    return unless matches

    matches.to_a[1..-1].join('.')
  end
end
