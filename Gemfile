# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.5.1'

gem 'actionmailer-text'
gem 'active_model_serializers'
gem 'angular-rails-templates'
gem 'authlogic'
gem 'autoprefixer-rails'
gem 'aws-sdk', '~> 2.4.x'
gem 'browser'
gem 'capistrano'
gem 'capistrano-bundler'
gem 'capistrano-rails'
gem 'capistrano-rbenv'
gem 'coffee-rails'
gem 'dalli'
gem 'dotenv-rails'
gem 'elasticsearch'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'font-awesome-rails'
gem 'formtastic'
gem 'friendly_id'
gem 'geokit'
gem 'geokit-rails'
gem 'gibbon' # mailchimp connect
gem 'gmaps4rails'
gem 'haml'
gem 'hashie'
gem 'htmlentities'
gem 'jbuilder' # non-html output (rss, atom)
gem 'jquery-rails'
gem 'lograge'
gem 'mime-types'
gem 'mojo_magick'
gem 'mysql2', '~> 0.4.x'
gem 'newrelic_rpm' # moitoring
gem 'ngannotate-rails'
gem 'nokogiri'
gem 'paperclip'
gem 'pickadate-rails'
gem 'postmark'
gem 'postmark-rails'
gem 'qr4r'
gem 'racc'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 5.1.4'
gem 'rdiscount' # markdown processor
gem 'recaptcha', require: 'recaptcha/rails'
gem 'responders'
gem 'rosie'
gem 'sass-color-extractor'
gem 'sassc-rails'
gem 'slim-rails'
gem 'uglifier'
gem 'unicorn' # webserver
gem 'xmlrpc' # after ruby 2.4 upgrade

source 'https://rails-assets.org' do
  gem 'rails-assets-angular', '=1.3.16'
  gem 'rails-assets-angular-animate', '=1.3.16'
  gem 'rails-assets-angular-mailchimp'
  gem 'rails-assets-angular-mocks'
  gem 'rails-assets-angular-moment'
  gem 'rails-assets-angular-resource', '=1.3.16'
  gem 'rails-assets-angular-sanitize', '=1.3.16'
  gem 'rails-assets-angular-ui-utils', '~> 0.2.3'
  gem 'rails-assets-c3'
  gem 'rails-assets-lodash'
  gem 'rails-assets-moment'
  gem 'rails-assets-ng-device-detector'
  gem 'rails-assets-ngDialog'
  gem 'rails-assets-pure'
  gem 'rails-assets-re-tree' # required for device-detector
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'cucumber-rails', require: false
  gem 'launchy' # Required to dump the page when running cucumber features
  gem 'poltergeist'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano3-unicorn'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-teaspoon'
  gem 'unicorn-rails'

  gem 'rails_best_practices'
end

group :test, :development do
  gem 'bundle-audit'
  gem 'byebug'
  gem 'database_cleaner'
  gem 'elasticsearch-extensions', require: nil
  gem 'factory_bot', require: false
  gem 'factory_bot_rails', require: false
  gem 'faker'
  gem 'jslint_on_rails'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git'
  gem 'simplecov'
  gem 'teaspoon-jasmine'
  gem 'timecop'
end
