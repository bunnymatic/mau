class MauMailer < ActionMailer::Base
  def mailer_list
    begin
      Object.const_get(self.class.name + 'List').first
    rescue Exception => ex
      logger.debug('There is no mailer for the %s class' % self.class.name)
      nil
    end
  end
  
end
