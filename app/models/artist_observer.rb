class ArtistObserver < ActiveRecord::Observer
  def after_create(artist)
    if artist.is_artist?
      artist.reload
      ArtistMailer.deliver_signup_notification(artist)
    end
  end

  def after_save(artist)
    if artist.is_artist?
      artist.reload
      ArtistMailer.deliver_activation(artist) if artist.recently_activated?
      ArtistMailer.deliver_reset_notification(artist) if artist.recently_reset?
      ArtistMailer.deliver_resend_activation(artist) if artist.resent_activation?
    end
  end
end
