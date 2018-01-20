# frozen_string_literal: true

begin
  require 'database_cleaner'
  require 'database_cleaner/cucumber'

  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise 'You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it.'
end

Before do |_scenario|
  DatabaseCleaner.start
end

After do |_scenario|
  DatabaseCleaner.clean
end
