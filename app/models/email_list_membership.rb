# == Schema Information
#
# Table name: email_list_memberships
#
#  id            :integer          not null, primary key
#  email_id      :integer
#  email_list_id :integer
#

class EmailListMembership < ActiveRecord::Base
  belongs_to :email_list
  belongs_to :email
  validates_uniqueness_of :email_list_id, :scope => :email_id
end
