class OpenStudiosTally < ApplicationRecord
  validates :oskey, presence: true
end
