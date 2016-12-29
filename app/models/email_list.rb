class EmailList < ApplicationRecord
  has_many :email_list_memberships
  has_many :emails, :through => :email_list_memberships

  def formatted_emails
    emails.map do |em|
      em.formatted
    end
  end

end
