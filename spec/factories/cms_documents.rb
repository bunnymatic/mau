# frozen_string_literal: true

FactoryBot.define do
  factory :cms_document do
    page { "page_#{Faker::Files.dir}" }
    section { Faker::Files.dir }
    article { "# this is an h1 header\n\n## this is an h2 header\n\n" + Faker::Lorem.paragraphs(2).join("\n") }
  end
end
