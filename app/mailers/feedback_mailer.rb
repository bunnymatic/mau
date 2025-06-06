class FeedbackMailer < MauMailer
  def feedback(feedback)
    emails = mailer_list&.formatted_emails.presence || ['jon@bunnymatic.com', 'trish@trishtunney.com']
    from = 'info@missionartists.org'
    reply_to = NO_REPLY_FROM_ADDRESS
    subject = "[Mission Artists Feedback] #{feedback.subject}"
    @feedback = feedback

    mail(to: emails, from:, reply_to:, subject:) do |fmt|
      fmt.html { render 'feedback' }
    end
  end
end
