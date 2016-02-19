class OpenStudiosTally < ActiveRecord::Base
  validates_presence_of :oskey
end
