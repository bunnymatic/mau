# frozen_string_literal: true
FactoryGirl.define do
  factory :email_list do
    trait :with_member do
      after(:create) do |list|
        list.update_attributes(emails: [ FactoryGirl.create(:email) ])
      end
    end
  end
  factory :admin_email_list, parent: :email_list, class: 'AdminMailerList'
  factory :feedback_email_list, parent: :email_list, class: 'FeedbackMailerList'
end
