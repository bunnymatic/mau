class AdminMailer < MauMailer
  def spammer(inf)
    if mailer_list.present?
      @recipients  =  mailer_list.formatted_emails
      @from        = 'info@missionartistsunited.org'
      @reply_to    = 'noreply@missionartistsunited.org'
      @subject     = "[MAU Spammer] possible spammer email on page #{inf['page']}"
      @sent_on     = Time.now
    end
    @body[:data] = inf
  end
end
