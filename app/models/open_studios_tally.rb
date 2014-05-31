# == Schema Information
#
# Table name: open_studios_tallies
#
#  id          :integer          not null, primary key
#  count       :integer
#  oskey       :string(255)
#  recorded_on :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class OpenStudiosTally < ActiveRecord::Base
  validates_presence_of :oskey
end
