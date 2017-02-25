# frozen_string_literal: true
class User
  module Authentication
    def mailer_class
      artist? ? ArtistMailer : UserMailer
    end

    def activate!
      mailer_class.activation(self).deliver_later
      update_attributes(state: 'active', activated_at: Time.zone.now)
    end
  end
end
