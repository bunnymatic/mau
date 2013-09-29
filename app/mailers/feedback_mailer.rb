class FeedbackMailer < MauMailer

  def feedback(feedback)
    emails = 'feedback@missionartistsunited.org','trish@trishtunney.com' #just in case
    if mailer_list.present?
      emails = mailer_list.formatted_emails
    end
    from        = 'info@missionartistsunited.org'
    reply_to    = 'noreply@missionartistsunited.org'
    subject     = "[MAU Feedback] #{feedback.subject}"
    @feedback = feedback

    mail(:to => emails, :from => from, :reply_to => reply_to, :subject => subject)

  end

end
