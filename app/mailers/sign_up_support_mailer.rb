class SignUpSupportMailer < MauMailer
  def secret_word_request(feedback)
    emails = 'feedback@missionartists.org', 'trish@trishtunney.com' # just in case
    emails = mailer_list.formatted_emails if mailer_list.present?
    from = 'info@missionartists.org'
    reply_to = NO_REPLY_FROM_ADDRESS
    subject = "[Mission Artists Support] Someone's trying to sign up"
    @feedback = feedback

    mail(to: emails, from:, reply_to:, subject:) do |fmt|
      fmt.html { render 'secret_word_request' }
    end
  end
end
