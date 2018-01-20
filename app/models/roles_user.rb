# frozen_string_literal: true

class RolesUser < ApplicationRecord
  validates :user_id, uniqueness: { scope: :role_id }
  belongs_to :user
  belongs_to :role

  def manager?
    role_id == Role.manager.id
  end
end
