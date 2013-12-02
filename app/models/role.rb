# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  role       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Role < ActiveRecord::Base
  has_many :roles_users, :dependent => :destroy
  has_many :users, :through => :roles_users

  validates_presence_of :role
  validates_uniqueness_of :role

  class << self
    def admin
      @@admin ||= Role.find_by_role("admin")
    end

    def manager
      @@manager ||= Role.find_by_role("manager")
    end

    def editor
      @@editor ||= Role.find_by_role("editor")
    end

  end

end
