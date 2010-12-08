class UserObserver < ActiveRecord::Observer
  def after_create(user)
    mailer_class = user.is_artist? ? ArtistMailer : UserMailer
    user.reload
    mailer_class.deliver_signup_notification(user)
  end

  def after_save(user)
    mailer_class = user.is_artist? ? ArtistMailer : UserMailer
    user.reload
    mailer_class.deliver_activation(user) if user.recently_activated?
    mailer_class.deliver_reset_notification(user) if user.recently_reset?
    mailer_class.deliver_resend_activation(user) if user.resent_activation?
  end
end
