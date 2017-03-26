# frozen_string_literal: true
FactoryGirl.define do
  factory :art_piece_tag do
    sequence(:name) { |n| "tag #{n}" }
  end
end
