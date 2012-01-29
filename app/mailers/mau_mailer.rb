class MauMailer < ActionMailer::Base
  def self.mailer_list
    begin
      Object.const_get(self.name + 'List')
    rescue Exception => ex
      logger.debug('There is no mailer for the %s class' % self.name)
      nil
    end
  end
  
end
