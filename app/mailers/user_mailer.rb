class UserMailer < MauMailer

  SUBJECT_PREFIX = "Mission Artists United"
  NOTE_FROM_ADDRESS = "Mission Artists United <mau@missionartistsunited.org>"
  ACCOUNTS_FROM_ADDRESS = "Mission Artists United Accounts <mau@missionartistsunited.org>"

  def activation(user)
    setup_email(user)
    subject = 'Your account has been activated!'
    @url  = Conf.site_url
    mail(:to => user.email, :from => ACCOUNTS_FROM_ADDRESS, :subject => build_subject(subject))
  end


  def signup_notification(user)
    setup_email(user)
    subject    = 'Please activate your new account'
    @url  = "http://%s/activate/#{user.activation_code}" % Conf.site_url
    mail(:to => user.email, :from => ACCOUNTS_FROM_ADDRESS, :subject => build_subject(subject))
  end

  def resend_activation(user)
    setup_email(user)
    subject   = 'Reactivate your MAU account'
    @url  = "http://%s/activate/#{user.activation_code}" % Conf.site_url
    mail(:to => user.email, :from => ACCOUNTS_FROM_ADDRESS, :subject => build_subject(subject))
  end

  def activation(user)
    setup_email(user)
    subject    = 'Your account has been activated!'
    @url  = Conf.site_url
    @usersurl  = 'http://%s/users/' % [ Conf.site_url, user.id ]
    mail(:to => user.email, :from => ACCOUNTS_FROM_ADDRESS, :subject => build_subject(subject))
  end


  def reset_notification(user)
    setup_email(user)
    subject    = 'Link to reset your password'
    @url  = "http://%s/reset/#{user.reset_code}" % Conf.site_url
    mail(:to => user.email, :from => ACCOUNTS_FROM_ADDRESS, :subject => build_subject(subject))
  end

  protected
  def setup_email(user)
    @user = user
  end

end
