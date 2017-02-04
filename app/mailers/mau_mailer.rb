class MauMailer < ActionMailer::Base

  SUBJECT_PREFIX = "Mission Artists"

  include ActionMailer::Text

  def mailer_list
    Object.const_get(self.class.name + 'List').first
  end

  protected
  def build_subject(subject)
    [SUBJECT_PREFIX, subject].join ' '
  end


end
