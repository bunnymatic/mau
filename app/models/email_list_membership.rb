# frozen_string_literal: true

class EmailListMembership < ApplicationRecord
  belongs_to :email_list
  belongs_to :email
  validates :email_list_id, uniqueness: { scope: :email_id }
end
