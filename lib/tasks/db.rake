# frozen_string_literal: true

unless Rails.env.production?
  namespace :db do
    desc 'Load set of data so that the application can start in a useful state'
    task sample_data: :environment do
      sample_data = Rails.root.join('db', 'sample_data.rb')
      load(sample_data) if sample_data
    end
  end
end

if Rails.env.development?
  namespace :db do
    desc 'Drop the database, reload the schema, run seeds and sample data.'
    task recreate: [
      'db:drop', 'db:create', 'db:schema:load', 'db:seed', 'db:sample_data'
    ]
  end
end
