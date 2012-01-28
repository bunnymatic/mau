class EmailListMembership < ActiveRecord::Base
  belongs_to :email_list
  belongs_to :email
end
