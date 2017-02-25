# frozen_string_literal: true
FactoryGirl.define do
  factory :medium do
    sequence(:name) {|n| "Medium #{n}" }
  end
end
