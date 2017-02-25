# frozen_string_literal: true
class ApplicationEvent < ApplicationRecord
  # do not use this class directly, but use one of its derivations
  validates :type, presence: true
  validates :type, length: { minimum: 2 }

  scope :by_recency, -> { order('created_at desc') }

  serialize :data, Hash

  after_save :publish_event

  def self.since(date)
    where(created_at: date..Time.now)
  end

  def publish_event
    Messager.new.publish "/events/#{self.class.to_s.tableize}", data
  end
end
