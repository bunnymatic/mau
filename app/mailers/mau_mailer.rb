class MauMailer < ActionMailer::Base

  SUBJECT_PREFIX = "Mission Artists United"

  def mailer_list
    begin
      Object.const_get(self.class.name + 'List').first
    rescue Exception => ex
      logger.debug('There is no mailer for the %s class' % self.class.name)
      nil
    end
  end

  protected
  def build_subject(subject)
    [SUBJECT_PREFIX, subject].join ' '
  end


end
