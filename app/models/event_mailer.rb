class EventMailer < ActionMailer::Base
  def event(ev)
    @recipients  = "events@missionartistsunited.org"
    @from        = 'noreply@missionartistsunited.org'
    @subject     = "[MAU Event Submission] New Event #{ev.title}: Starttime #{ev.starttime.localtime.asctime}"
    @sent_on     = Time.now
    @body[:event] = ev
  end

  def event_published(ev)
    @recipients = ev.user.email
    @from = 'noreply@missionartistsunited.org'
    @subject = 'We published your event!'
    @sent_on = Time.now
    @body[:event] = ev
  end
    
end
