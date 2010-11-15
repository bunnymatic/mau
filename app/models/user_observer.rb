class UserObserver < ActiveRecord::Observer
  def after_create(user)
    if !user.is_artist?
      user.reload
      UserMailer.deliver_signup_notification(user)
    end
  end

  def after_save(user)
    if !user.is_artist?
      user.reload
      UserMailer.deliver_activation(user) if user.recently_activated?
      UserMailer.deliver_reset_notification(user) if user.recently_reset?
      UserMailer.deliver_resend_activation(user) if user.resent_activation?
    end
  end

end
