# == Schema Information
#
# Table name: roles_users
#
#  id      :integer          not null, primary key
#  user_id :integer
#  role_id :integer
#

class RolesUser < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => :role_id
  belongs_to :user
  belongs_to :role

  def is_manager_role?
    role_id == Role.manager.id
  end

end
