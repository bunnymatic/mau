class FeedbackMailer < MauMailer
  
  def feedback(feedback)
    emails = 'feedback@missionartistsunited.org','trish@trishtunney.com' #just in case
    if mailer_list.present?
      emails = mailer_list.formatted_emails
    end
    @recipients  =  emails
    @from        = 'noreply@missionartistsunited.org'
    @subject     = "[MAU Feedback] #{feedback.subject}"
    @sent_on     = Time.now
    @body[:feedback] = feedback

  end

end

