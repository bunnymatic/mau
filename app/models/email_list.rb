# == Schema Information
#
# Table name: email_lists
#
#  id         :integer          not null, primary key
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_email_lists_on_type  (type) UNIQUE
#

class EmailList < ActiveRecord::Base
  has_many :email_list_memberships
  has_many :emails, :through => :email_list_memberships

  def formatted_emails
    emails.map do |em|
      em.formatted
    end
  end

end
