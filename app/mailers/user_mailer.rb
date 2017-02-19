class UserMailer < MauMailer

  def activation(user)
    setup_email(user)
    subject = 'Your account has been activated!'
    @url  = Conf.site_url
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'activation' }
    end
  end


  def signup_notification(user)
    setup_email(user)
    subject    = 'Please activate your new account'
    @url  = "http://%s/activate/#{user.activation_code}" % Conf.site_url
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'signup_notification' }
    end
  end

  def resend_activation(user)
    setup_email(user)
    subject   = 'Reactivate your MAU account'
    @url  = "http://%s/activate/#{user.activation_code}" % Conf.site_url
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'resend_activation' }
    end
  end

  def reset_notification(user)
    setup_email(user)
    subject    = 'Link to reset your password'
    @url  = "http://%s/reset/#{user.reset_code}" % Conf.site_url
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'reset_notification' }
    end
  end

  protected
  def setup_email(user)
    @user = user
  end

end
