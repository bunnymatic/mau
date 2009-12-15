class ArtistObserver < ActiveRecord::Observer
  def after_create(artist)
    artist.reload
    ArtistMailer.deliver_signup_notification(artist)
  end

  def after_save(artist)
    artist.reload
    ArtistMailer.deliver_activation(artist) if artist.recently_activated?
    ArtistMailer.deliver_reset_notification(artist) if artist.recently_reset?
    ArtistMailer.deliver_resend_activation(artist) if artist.resent_activation?
  end

end
