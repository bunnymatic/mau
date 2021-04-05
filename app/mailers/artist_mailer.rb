class ArtistMailer < MauMailer
  def favorite_notification(artist, fan)
    setup_email(artist)
    subject = 'Someone hearts you! ❤'

    @sender = fan
    @artist_url = artist_url(@artist)

    mail(to: artist.email,
         from: NOTE_FROM_ADDRESS,
         reply_to: NO_REPLY_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'favorite_notification' }
    end
  end

  def signup_notification(artist)
    subject = 'Please activate your new account'
    setup_email(artist)
    @url = activate_url(activation_code: artist.activation_code)
    @open_studios_registration_url = register_open_studios_url
    mail(to: artist.email,
         from: ACCOUNTS_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'signup_notification' }
    end
  end

  def resend_activation(artist)
    setup_email(artist)
    subject = 'Reactivate your MAU account'
    @url = activate_url(activation_code: artist.activation_code)
    mail(to: artist.email,
         from: ACCOUNTS_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'resend_activation' }
    end
  end

  def activation(artist)
    setup_email(artist)
    subject = 'Your account has been activated!'
    @url = root_url
    @artistsurl = artist_url(artist)
    @open_studios_registration_url = register_open_studios_url
    mail(to: artist.email,
         from: ACCOUNTS_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'activation' }
    end
  end

  def reset_notification(artist)
    setup_email(artist)
    subject = 'Link to reset your password'
    @url = reset_url(reset_code: artist.reset_code)
    mail(to: artist.email,
         from: ACCOUNTS_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'reset_notification' }
    end
  end

  def welcome_to_open_studios(artist, current_os)
    setup_email(artist)
    subject = "Welcome To Open Studios #{current_os.for_display(reverse: true)}"
    @current_os = current_os
    @upload_url = manage_art_artist_url(artist)
    @donation_url = edit_artist_url(artist, anchor: 'events')
    @artist_os_section_url = edit_artist_url(artist, anchor: 'events')
    @studio_address = artist.address
    mail(to: artist.email,
         from: ACCOUNTS_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'welcome_to_open_studios' }
    end
  end

  def contact_about_art(artist, art_piece, contact_info)
    setup_email(artist)
    subject = 'Someone likes your art!'
    @name = contact_info[:name]
    @phone = contact_info[:phone]
    @email = contact_info[:email]
    @message = contact_info[:message]
    @art_piece = art_piece
    mail(to: artist.email,
         from: NOTE_FROM_ADDRESS,
         reply_to: NO_REPLY_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'contact_about_art' }
    end
  end

  protected

  def setup_email(artist)
    @artist = artist
  end
end
