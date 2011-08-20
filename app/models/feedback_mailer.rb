class FeedbackMailer < ActionMailer::Base
  
  @@FEEDBACK_EMAIL_LIST = Conf.feedback_emails
  def feedback(feedback)
    if !@@FEEDBACK_EMAIL_LIST || @@FEEDBACK_EMAIL_LIST.empty?
      logger.info("No one to mail feedback to!")
    else
      @recipients  = @@FEEDBACK_EMAIL_LIST
      @from        = 'noreply@missionartistsunited.org'
      @subject     = "[MAU Feedback] #{feedback.subject}"
      @sent_on     = Time.now
    end
    @body[:feedback] = feedback

  end

end
