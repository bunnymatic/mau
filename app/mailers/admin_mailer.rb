class AdminMailer < MauMailer
  def spammer(inf)
    from        = 'info@missionartistsunited.org'
    reply_to    = 'noreply@missionartistsunited.org'
    subject     = "[MAU Spammer] possible spammer email on page #{inf['page']}"

    @data = inf

    mail(:to => mailer_list.formatted_emails, :from => from, :reply_to => reply_to, :subject => subject) do |fmt|
      fmt.html { render 'spammer' }
    end

  end
end
