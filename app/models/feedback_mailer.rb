class FeedbackMailer < ActionMailer::Base
  
  def feedback(feedback)
    @recipients  = 'webmaster@missionartistsunited.org'
    @from        = 'noreply@missionartistsunited.org'
    @subject     = "[Feedback for YourSite] #{feedback.subject}"
    @sent_on     = Time.now
    @body[:feedback] = feedback    
  end

end
