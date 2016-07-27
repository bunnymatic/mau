class Email < ApplicationRecord

  has_many :email_list_memberships
  has_many :email_list, :through => :email_list_membership
  validates_presence_of :email
  validates_format_of :email,    :with => Mau::Regex::EMAIL, :message => Mau::Regex::BAD_EMAIL_MESSAGE

  def formatted
    name.present? ? "#{name} <#{email}>" : email
  end

  # def self.find_or_create props
  #   email = Email.new(props)
  #   found = Email.find_by_email(email.email)
  #   found ? found : email
  # end

end
