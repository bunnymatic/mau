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

class RecruitingMailerList < EmailList

end
