class FeedbackMailer < MauMailer

  def feedback(feedback)
    emails = 'feedback@missionartistsunited.org','trish@trishtunney.com' #just in case
    if mailer_list.present?
      emails = mailer_list.formatted_emails
    end
    @recipients  =  emails
    @from        = 'info@missionartistsunited.org'
    @reply_to    = 'noreply@missionartistsunited.org'
    @subject     = "[MAU Feedback] #{feedback.subject}"
    @body[:feedback] = feedback

  end

end
