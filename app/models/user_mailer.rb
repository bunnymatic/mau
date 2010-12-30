class UserMailer < ActionMailer::Base
  def activation(user)
    setup_email(user)
    @subject    += ': Your account has been activated!'
    @body[:url]  = Conf.site_url
  end
  

  def signup_notification(user)
    setup_email(user)
    @subject    += ': Please activate your new account'  
    @body[:url]  = "http://%s/activate/#{user.activation_code}" % Conf.site_url
  end


  def notify(user, notehash)
    setup_note(user)
    @subject += "You just got a note!"
    @sender_name = notehash['name']
    @sender_email = notehash['email']
    @sender_note = notehash['comment']
  end
             

  def resend_activation(user)
    setup_email(user)
    @subject    += 'Reactivate your MAU account'  
    @body[:url]  = "http://%s/activate/#{user.activation_code}" % Conf.site_url
  end

  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = Conf.site_url
    @body[:usersurl]  = 'http://%s/users/' % [ Conf.site_url, user.id ]
  end
  

  def reset_notification(user)
    setup_email(user)
    @subject    += 'Link to reset your password'
    @body[:url]  = "http://%s/reset/#{user.reset_code}" % Conf.site_url
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Mission Artists United Accounts <mauadmin@missionusersunited.org>"
      @subject     = "Mission Artists United "
      @sent_on     = Time.now
      @body[:user] = user
    end
    def setup_note(user)
      @recipients  = "#{user.email}"
      @from        = "Mission Artists United <mau@missionusersunited.org>"
      @subject     = "Mission Artists United "
      @sent_on     = Time.now
      @body[:user] = user
    end
    
end
