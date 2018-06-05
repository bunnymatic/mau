# frozen_string_literal: true

FactoryBot.define do
  factory :email_list do
    trait :with_member do
      after(:create) do |list|
        list.update(emails: [FactoryBot.create(:email)])
      end
    end
  end
  factory :watcher_email_list, parent: :email_list, class: 'WatcherMailerList'
  factory :admin_email_list, parent: :email_list, class: 'AdminMailerList'
  factory :feedback_email_list, parent: :email_list, class: 'FeedbackMailerList'
end
