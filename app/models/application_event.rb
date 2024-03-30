class ApplicationEvent < ApplicationRecord
  # do not use this class directly, but use one of its derivations
  validates :type, presence: true
  validates :type, length: { minimum: 2 }

  scope :available_types, -> { distinct(:type).order(:type).pluck(:type) }
  scope :by_recency, -> { order('created_at desc') }
  scope :since, ->(date) { where(created_at: date..Time.zone.now) }

  serialize :data, type: Hash
end
