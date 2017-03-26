# frozen_string_literal: true
class UserMailer < MauMailer
  def activation(user)
    setup_email(user)
    subject = 'Your account has been activated!'
    @url = root_url
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'activation' }
    end
  end

  def signup_notification(user)
    setup_email(user)
    subject = 'Please activate your new account'
    @url = activate_url(activation_code: user.activation_code)
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'signup_notification' }
    end
  end

  def resend_activation(user)
    setup_email(user)
    subject = 'Reactivate your MAU account'
    @url = activate_url(activation_code: user.activation_code)
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'resend_activation' }
    end
  end

  def reset_notification(user)
    setup_email(user)
    subject = 'Link to reset your password'
    @url = reset_url(reset_code: user.reset_code)
    mail(to: user.email, from: ACCOUNTS_FROM_ADDRESS, subject: build_subject(subject)) do |fmt|
      fmt.html { render 'reset_notification' }
    end
  end

  protected

  def setup_email(user)
    @user = user
  end
end
