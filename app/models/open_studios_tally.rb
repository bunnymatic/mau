# frozen_string_literal: true

class OpenStudiosTally < ApplicationRecord
  validates :oskey, presence: true
end
