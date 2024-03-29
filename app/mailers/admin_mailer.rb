class AdminMailer < MauMailer
  def spammer(inf)
    from        = 'info@missionartists.org'
    reply_to    = NO_REPLY_FROM_ADDRESS
    subject     = "[MAU Spammer]#{environment_for_subject} possible spammer email on page #{inf['page']}"

    @data = inf

    mail(
      to: mailer_list.formatted_emails,
      from:,
      reply_to:,
      subject:,
    ) do |fmt|
      fmt.html { render 'spammer' }
    end
  end

  def server_trouble(status)
    from        = 'info@missionartists.org'
    reply_to    = NO_REPLY_FROM_ADDRESS
    subject     = "[MAU Admin]#{environment_for_subject} server trouble..."

    @status = status
    mail(
      to: mailer_list.formatted_emails,
      from:,
      reply_to:,
      subject:,
    ) do |fmt|
      fmt.html { render 'server_trouble' }
    end
  end
end
