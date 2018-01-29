# frozen_string_literal: true

source 'https://rubygems.org'
ruby '2.4.1'

gem 'active_model_serializers'
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano-rbenv'
gem 'dalli'
gem 'font-awesome-rails'
gem 'formtastic'
gem 'friendly_id'
gem 'haml'
gem 'hashie'
gem 'htmlentities'
gem 'jquery-rails'
gem 'lograge'
gem 'mojo_magick'
gem 'mysql2', '~> 0.4.x'
gem 'nokogiri'
gem 'racc'
gem 'rails', '5.1.4'
gem 'rdiscount' # markdown processor
gem 'responders'
gem 'slim-rails'

gem 'elasticsearch', '~> 2.x'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

gem 'gibbon' # mailchimp connect
gem 'rosie'

gem 'aws-sdk', '~> 2.4.x'
gem 'browser'
gem 'geokit'
gem 'geokit-rails'
gem 'gmaps4rails'
gem 'mime-types'
gem 'paperclip'
gem 'pickadate-rails'
gem 'qr4r'
gem 'rack-cors', require: 'rack/cors'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'xmlrpc' # after ruby 2.4 upgrade

gem 'angular-rails-templates'
gem 'ngannotate-rails'

# authentication
gem 'authlogic'
# mailing with postmarkapp.com
gem 'postmark'
gem 'postmark-rails'

gem 'unicorn' # webserver

gem 'jbuilder' # non-html output (rss, atom)

gem 'newrelic_rpm' # moitoring

gem 'dotenv-rails'

gem 'autoprefixer-rails'
gem 'coffee-rails'
gem 'sassc-rails'

gem 'uglifier'

gem 'actionmailer-text'

gem 'sass-color-extractor'

gem 'bootsnap', require: false

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
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano3-unicorn'
  gem 'spring'
  gem 'spring-commands-teaspoon'
  gem 'spring-commands-rspec'
  gem 'unicorn-rails'

  gem 'rails_best_practices'
end

group :test, :development do
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
  gem 'simplecov'
  gem 'shoulda-matchers'
  gem 'teaspoon-jasmine'
  gem 'timecop'
end
