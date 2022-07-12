class Notification < ApplicationRecord
  validates :message, presence: true

  scope :active, -> { where.not(activated_at: nil).where(activated_at: ..Time.zone.now) }
end
