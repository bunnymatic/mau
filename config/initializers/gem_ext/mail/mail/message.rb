require 'mail'
module Mail
  class Message
    alias :old_deliver! :deliver!
    def deliver!
      Rails.logger.debug "DID NOT SEND : #{self.to_s}"
      unless /MAU\ Feedback/ =~ self.subject
        old_deliver!
      end
    end
  end
end
