# frozen_string_literal: true

class AdminMailer < MauMailer
  def spammer(inf)
    from        = 'info@missionartists.org'
    reply_to    = 'noreply@missionartists.org'
    subject     = "[MAU Spammer]#{environment} possible spammer email on page #{inf['page']}"

    @data = inf

    mail(
      to: mailer_list.formatted_emails,
      from: from,
      reply_to: reply_to,
      subject: subject
    ) do |fmt|
      fmt.html { render 'spammer' }
    end
  end

  def server_trouble(status)
    from        = 'info@missionartists.org'
    reply_to    = 'noreply@missionartists.org'
    subject     = "[MAU Admin]#{environment} server trouble..."

    @status = status
    mail(
      to: mailer_list.formatted_emails,
      from: from,
      reply_to: reply_to,
      subject: subject
    ) do |fmt|
      fmt.html { render 'server_trouble' }
    end
  end

  private

  def environment
    return '' if Rails.env.production?
    "[#{Rails.env}]"
  end
end
