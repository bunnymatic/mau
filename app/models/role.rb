class Role < ActiveRecord::Base
  has_many :roles_users, :dependent => :destroy
  has_many :users, :through => :roles_users

  validates_presence_of :role
  validates_uniqueness_of :role
end

