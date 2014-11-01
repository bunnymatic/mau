FactoryGirl.define do
  factory :email_list
  factory :event_email_list, class: 'EventMailerList'
  factory :admin_email_list, class: 'AdminMailerList'
  factory :feedback_email_list, class: 'FeedbackMailerList'
end
