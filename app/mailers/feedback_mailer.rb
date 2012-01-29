class FeedbackMailer < MauMailer
  
  def feedback(feedback)
    email_list = FeedbackMailerList.first
    if email_list.present?
      @recipients  =  email_list.formatted_emails
      @from        = 'noreply@missionartistsunited.org'
      @subject     = "[MAU Feedback] #{feedback.subject}"
      @sent_on     = Time.now
    end
    @body[:feedback] = feedback

  end

end

