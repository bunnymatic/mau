# frozen_string_literal: true

FactoryBot.define do
  factory :medium do
    sequence(:name) { |n| "Medium #{n}" }
  end
end
