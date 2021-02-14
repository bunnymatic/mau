class Feedback < ApplicationRecord
  validates :comment, presence: true
  validates :subject, presence: true
end
