class FeedbackMailer < MauMailer
  
  def feedback(feedback)
    if mailer_list.present?
      @recipients  =  mailer_list.formatted_emails
      @from        = 'noreply@missionartistsunited.org'
      @subject     = "[MAU Feedback] #{feedback.subject}"
      @sent_on     = Time.now
    end
    @body[:feedback] = feedback

  end

end

