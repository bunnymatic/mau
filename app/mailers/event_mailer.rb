class EventMailer < MauMailer
  def event_added(ev)
    @event = ev

    recipients  =  mailer_list.formatted_emails
    from        = 'info@missionartistsunited.org'
    reply_to    = 'noreply@missionartistsunited.org'
    subject     = "[MAU Event Submission] New Event #{ev.title}: Starttime #{ev.starttime.localtime.asctime}"

    mail(:to => mailer_list.formatted_emails, :from => from, :reply_to => reply_to, :subject => subject)
  end

  def event_published(ev)
    @event = ev

    recipients = ev.user.email
    from       = 'info@missionartistsunited.org'
    reply_to   = 'noreply@missionartistsunited.org'
    subject = 'We published your event!'

    mail(:to => ev.user.email, :from => from, :reply_to => reply_to, :subject => subject)

  end
end
