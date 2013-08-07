class EventMailer < MauMailer
  def event_added(ev)
    if mailer_list.present?
      @recipients  =  mailer_list.formatted_emails
      @from        = 'info@missionartistsunited.org'
      @reply_to    = 'noreply@missionartistsunited.org'
      @subject     = "[MAU Event Submission] New Event #{ev.title}: Starttime #{ev.starttime.localtime.asctime}"
    end
    @body[:event] = ev
  end

  def event_published(ev)
    @recipients = ev.user.email
    @from       = 'info@missionartistsunited.org'
    @reply_to   = 'noreply@missionartistsunited.org'
    @subject = 'We published your event!'
    @body[:event] = ev
  end
end
