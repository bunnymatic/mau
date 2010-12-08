class ArtistMailer < ActionMailer::Base
  def activation(artist)
    setup_email(artist)
    @subject    += ': Your account has been activated!'
    @body[:url]  = Conf.site_url
  end
  

  def signup_notification(artist)
    setup_email(artist)
    p "ARTIST ", artist
    @subject    += ': Please activate your new account'  
    @body[:url]  = "http://%s/activate/#{artist.activation_code}" % Conf.site_url
  end


  def notify(artist, notehash)
    setup_note(artist)
    @subject += "You just got a note!"
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
      @from        = "Mission Artists United Accounts <mauadmin@missionartistsunited.org>"
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
