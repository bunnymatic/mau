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

class GenericEvent < ApplicationEvent
end
