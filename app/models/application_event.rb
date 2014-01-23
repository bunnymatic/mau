# == Schema Information
#
# Table name: application_events
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  message    :string(255)
#  data       :text
#  created_at :datetime
#  updated_at :datetime
#

class ApplicationEvent < ActiveRecord::Base
  # do not use this class directly, but use one of its derivations
  validates_presence_of :type
  validates_length_of :type, :minimum => 2

  scope :by_recency, order('created_at desc')

  serialize :data, Hash

  after_save :publish_event

  def publish_event
    Messager.new.publish "/events/#{self.class.to_s.tableize}", data
  end

end
