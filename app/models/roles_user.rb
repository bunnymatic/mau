# == Schema Information
#
# Table name: roles_users
#
#  user_id :integer
#  role_id :integer
#  id      :integer          not null, primary key
#

class RolesUser < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => :role_id
  belongs_to :user
  belongs_to :role
end
