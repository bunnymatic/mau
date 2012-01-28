class EmailList < ActiveRecord::Base
  has_many :email_list_memberships
  has_many :emails, :through => :email_list_memberships
  validates_presence_of :type
end
