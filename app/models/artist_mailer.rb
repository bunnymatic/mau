class ArtistMailer < ActionMailer::Base
  def signup_notification(artist)
    setup_email(artist)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://%s/#{artist.activation_code}" % Conf.site_url
  
  end
  
  def activation(artist)
    setup_email(artist)
    @subject    += 'Your account has been activated!'
    @body[:url]  = Conf.site_url
  end
  
  def signup_notification(artist)
    setup_email(artist)
    @subject    += 'Please activate your new account'  
    @body[:url]  = "http://%s/activate/#{artist.activation_code}" % Conf.site_url
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
    
end
