# frozen_string_literal: true
module UsersHelper
  def user_signup_select_options(user, type)
    user.password = user.password_confirmation = nil
    entries = [['<select your account type>', ''],
               ['Mission Art Fan', :MauFan],
               ['Mission Artist', :Artist]]
    options = {
      disabled: [entries.first.first],
      selected: [type.present? ? type : entries.first.first]
    }
    options_for_select( entries, options )
  end
end
