class ArtistMailer < MauMailer
  NOTE_FROM_ADDRESS = "Mission Artists United <mau@missionartistsunited.org>"
  ACCOUNTS_FROM_ADDRESS = "Mission Artists United Accounts <mau@missionartistsunited.org>"

  def activation(artist)
    subject = "Your account has been activated!"
    setup_email(artist)
    mail(:to => artist.email,
         :from => ACCOUNTS_FROM_ADDRESS,
         :subject => build_subject(subject))
  end

  def favorite_notification(artist, fan)
    setup_email(artist)
    subject = 'Someone hearts you on Mission Artists United'

    @sender = fan
    @notification_url = edit_artist_url(@artist, anchor: "notifications")
    @artist_url = artist_url(@artist)

    mail(:to => artist.email,
         :from => ACCOUNTS_FROM_ADDRESS,
         :subject => build_subject(subject))

  end

  def signup_notification(artist)
    subject = 'Please activate your new account'
    setup_email(artist)
    @url  = activate_url(:activation_code => artist.activation_code)
    mail(:to => artist.email,
         :from => ACCOUNTS_FROM_ADDRESS,
         :subject => build_subject(subject))
  end

  def notify_featured(artist)
    setup_email(artist)
    subject = "You've been featured by Mission Artists United."
    mail(:to => artist.email,
         :from => NOTE_FROM_ADDRESS,
         :subject => build_subject(subject))
  end

  def resend_activation(artist)
    setup_email(artist)
    subject    = 'Reactivate your MAU account'
    @url  = activate_url(:activation_code => artist.activation_code)
    mail(:to => artist.email,
         :from => ACCOUNTS_FROM_ADDRESS,
         :subject => build_subject(subject))
  end

  def activation(artist)
    setup_email(artist)
    subject    = 'Your account has been activated!'
    @url  = Conf.site_url
    @artistsurl  = artist_url(artist)
    mail(:to => artist.email,
         :from => ACCOUNTS_FROM_ADDRESS,
         :subject => build_subject(subject))
  end

  def reset_notification(artist)
    setup_email(artist)
    subject    = 'Link to reset your password'
    @url  = "http://%s/reset/#{artist.reset_code}" % Conf.site_url
    mail(:to => artist.email,
         :from => ACCOUNTS_FROM_ADDRESS,
         :subject => build_subject(subject))
  end

  protected
  def setup_email(artist)
    @artist = artist
  end

end
