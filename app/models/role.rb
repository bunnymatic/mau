class Role < ApplicationRecord
  has_many :roles_users, :dependent => :destroy
  has_many :users, :through => :roles_users

  validates_presence_of :role
  validates_uniqueness_of :role

  class << self
    def admin
      Role.find_by_role("admin")
    end

    def manager
      Role.find_by_role("manager")
    end

    def editor
      Role.find_by_role("editor")
    end

  end

end
