# frozen_string_literal: true
class Role < ApplicationRecord
  has_many :roles_users, dependent: :destroy
  has_many :users, through: :roles_users

  validates :role, presence: true
  validates :role, uniqueness: true

  class << self
    def admin
      Role.find_by(role: 'admin')
    end

    def manager
      Role.find_by(role: 'manager')
    end

    def editor
      Role.find_by(role: 'editor')
    end
  end
end
