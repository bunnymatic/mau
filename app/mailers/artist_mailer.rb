# frozen_string_literal: true

class ArtistMailer < MauMailer
  def favorite_notification(artist, fan)
    setup_email(artist)
    subject = 'Someone hearts you! ❤'

    @sender = fan
    @artist_url = artist_url(@artist)

    mail(to: artist.email,
         from: NOTE_FROM_ADDRESS,
         subject: build_subject(subject)) do |fmt|
      fmt.html { render 'favorite_notification' }
    end
  end

  def signup_notification(artist)
    subject = 'Please activate your new account'
    setup_email(artist)
    @url = activate_url(activation_code: artist.activation_code)
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

  protected

  def setup_email(artist)
    @artist = artist
  end
end
