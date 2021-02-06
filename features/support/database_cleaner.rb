# frozen_string_literal: true

begin
  require 'database_cleaner/active_record'
  require 'database_cleaner/cucumber'

  # This app seems to have some trouble with `:transaction` and flipping to `:truncation` only
  # for JS tests so, let's just leave it alone.
  # For more details: https://github.com/cucumber/cucumber-rails/issues/490
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
