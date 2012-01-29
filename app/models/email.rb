class Email < ActiveRecord::Base
  include Authentication # strictly for email regex
  has_many :email_list_membershipss
  has_many :email_list, :through => :email_list_membership
  validates_presence_of :email
  validates_format_of :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  
  def formatted
    name.present? ? "#{name} <#{email}>" : email
  end

  def self.find_or_create props
    email = Email.new(props)
    found = Email.find_by_email(email.email)
    found ? found : email
  end
      
end
