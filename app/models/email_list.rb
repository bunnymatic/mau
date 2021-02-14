class EmailList < ApplicationRecord
  has_many :email_list_memberships
  has_many :emails, through: :email_list_memberships, dependent: :destroy

  def formatted_emails
    emails.map(&:formatted)
  end
end
