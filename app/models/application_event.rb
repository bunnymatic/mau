class ApplicationEvent < ActiveRecord::Base
  # do not use this class directly, but use one of its derivations
  validates_presence_of :type
  validates_length_of :type, :minimum => 2
  default_scope :order => 'created_at desc'
  serialize :data, Hash
  
  after_save :publish_event
  
  def publish_event
  #  begin
      EventSubscriber.find_all_by_event_type(self.class.to_s).each do |subscriber|
        subscriber.publish(self)
      end
  #  rescue Exception => ex
      #RAILS_DEFAULT_LOGGER.warn("Failed to send event #{self.inspect} to subscriber: #{ex}")
  #  end
    true
  end
end
