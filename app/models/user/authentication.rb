class User
  module Authentication
    def mailer_class
      mailer_class = is_artist? ? ArtistMailer : UserMailer
    end

    def activate!
      mailer_class.activation(self).deliver!
      self.update_attributes( state: active, activated_at: Time.zone.now)
      FeaturedArtistQueue.create(:artist_id => id, :position => rand) if is_artist?
    end
  end

end
