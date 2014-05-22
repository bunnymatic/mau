module Concerns
  module Authentication
    def mailer_class
      mailer_class = is_artist? ? ArtistMailer : UserMailer
    end
    
    def activate!
      mailer_class.activation(self).deliver!
      FeaturedArtistQueue.create(:artist_id => id, :position => rand) if is_artist?
    end
  end
end
