class Feedback < ActiveRecord::Base

  validates_presence_of :comment
  validates_presence_of :subject

end
