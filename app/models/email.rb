class Email < ActiveRecord::Base
  include Authentication # strictly for email regex
  has_many :email_list_membershipss
  has_many :email_list, :through => :email_list_membership
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
end
