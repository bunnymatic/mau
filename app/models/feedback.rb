# == Schema Information
#
# Table name: feedbacks
#
#  id         :integer          not null, primary key
#  subject    :string(255)
#  email      :string(255)
#  login      :string(255)
#  page       :string(255)
#  comment    :text
#  created_at :datetime
#  updated_at :datetime
#  url        :string(255)
#  skillsets  :string(255)
#  bugtype    :string(255)
#

class Feedback < ActiveRecord::Base

  validates_presence_of :comment
  validates_presence_of :subject

end
