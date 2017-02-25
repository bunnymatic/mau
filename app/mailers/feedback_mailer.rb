# frozen_string_literal: true
class FeedbackMailer < MauMailer
  def feedback(feedback)
    emails = 'feedback@missionartists.org','trish@trishtunney.com' # just in case
    emails = mailer_list.formatted_emails if mailer_list.present?
    from        = 'info@missionartists.org'
    reply_to    = 'noreply@missionartists.org'
    subject     = "[Mission Artists Feedback] #{feedback.subject}"
    @feedback = feedback

    mail(to: emails, from: from, reply_to: reply_to, subject: subject) do |fmt|
      fmt.html { render "feedback" }
    end
  end
end
