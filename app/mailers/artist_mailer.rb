class ArtistMailer < MauMailer
  def activation(artist)
    setup_email(artist)
    @subject    += ': Your account has been activated!'
    @body[:url]  = Conf.site_url
  end
  
  def favorite_notification(artist, fan)
    setup_email(artist)
    @subject = 'Someone hearts you on Mission Artists United'

    @sender = fan
    @artist = artist
    @notification_url = url_for(:host => Conf.site_url, :controller => 'artists', :action => 'edit') + '#notifications'    
    @artist_url = url_for(:host => Conf.site_url, :controller => 'artists', :action => 'show', :id => @artist.id)
  end

  def signup_notification(artist)
    setup_email(artist)
    @subject    += ': Please activate your new account'  
    @body[:url]  = "http://%s/activate/#{artist.activation_code}" % Conf.site_url
  end


  def notify(artist, notehash)
    setup_note(artist)
    @subject = "An inquiry about your art."
    @sender_name = notehash['name']
    @sender_email = notehash['email']
    @sender_note = notehash['comment']
  end
             

  def resend_activation(artist)
    setup_email(artist)
    @subject    += 'Reactivate your MAU account'  
    @body[:url]  = "http://%s/activate/#{artist.activation_code}" % Conf.site_url
  end

  def activation(artist)
    setup_email(artist)
    @subject    += 'Your account has been activated!'
    @body[:url]  = Conf.site_url
    @body[:artistsurl]  = 'http://%s/artists/' % [ Conf.site_url, artist.id ]
  end
  

  def reset_notification(artist)
    setup_email(artist)
    @subject    += 'Link to reset your password'
    @body[:url]  = "http://%s/reset/#{artist.reset_code}" % Conf.site_url
  end
  
  protected
    def setup_email(artist)
      @recipients  = "#{artist.email}"
      @from        = "Mission Artists United Accounts <mau@missionartistsunited.org>"
      @subject     = "Mission Artists United "
      @sent_on     = Time.now
      @body[:artist] = artist
    end
    def setup_note(artist)
      @recipients  = "#{artist.email}"
      @from        = "Mission Artists United <mau@missionartistsunited.org>"
      @subject     = "Mission Artists United "
      @sent_on     = Time.now
      @body[:artist] = artist
    end
    
end
