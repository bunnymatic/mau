# frozen_string_literal: true

FactoryBot.define do
  factory(:email) do
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end
