class User
  module Authentication
    def mailer_class
      artist? ? ArtistMailer : UserMailer
    end

    def activate!
      mailer_class.activation(self).deliver_later
      update(state: Constants::User::STATE_ACTIVE, activated_at: Time.zone.now)
    end
  end
end
