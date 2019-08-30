# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.6.1'

gem 'actionmailer-text'
gem 'active_model_serializers'
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
gem 'faraday'
gem 'faraday_middleware'
gem 'font-awesome-rails'
gem 'formtastic'
gem 'friendly_id'
gem 'geokit'
gem 'geokit-rails'
gem 'gibbon' # mailchimp connect
gem 'gmaps4rails'
gem 'hashie'
gem 'htmlentities'
gem 'jbuilder' # non-html output (rss, atom)
gem 'jquery-rails'
gem 'listen'
gem 'lograge'
gem 'mime-types'
gem 'mojo_magick'
gem 'mysql2'
gem 'newrelic_rpm' # moitoring
gem 'ngannotate-rails'
gem 'nokogiri'
gem 'paperclip'
gem 'pickadate-rails'
gem 'postmark'
<<<<<<< HEAD
gem 'postmark-rails'
gem 'puma'
gem 'qr4r'
gem 'racc'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 5.2.x'
gem 'rdiscount' # markdown processor
gem 'recaptcha', require: 'recaptcha/rails'
gem 'responders'
gem 'rosie'
gem 'sassc-rails'
gem 'slim-rails'
gem 'sprockets', '~> 3.7.2'
=======

gem 'unicorn' # webserver

gem 'flot-rails' # jquery plotting program

gem 'select2-rails' # autocompleter

gem 'underscore-string-rails'

gem 'jbuilder' #non-html output (rss, atom)

gem 'newrelic_rpm' #moitoring

gem 'dotenv-rails'

gem 'sass-rails'
gem 'coffee-rails'
# uglifier 2.7.2 breaks Angular in feature specs on CI. Connecting to CircleCI over VNC
# (https://circleci.com/docs/browser-debugging#interact-with-the-browser-over-vnc)
# shows the error: "[$injector:unpr] Unknown provider: tProvider <- t <- $http <- $templateRequest <- $compile"
# The changelog for `uglifier` shows an upgrade from UglifyJS2 2.4.16 to 2.4.24,
# (https://github.com/mishoo/UglifyJS2/compare/v2.4.16...v2.4.24)
# but I couldn't find a changelog for that to help figure out why it breaks our minification
>>>>>>> parent of 302f5f47... move config files to puma
gem 'uglifier'
gem 'unicorn' # webserver
gem 'xmlrpc' # after ruby 2.4 upgrade

source 'https://rails-assets.org' do
  gem 'rails-assets-c3'
  gem 'rails-assets-datatables'
  gem 'rails-assets-pure'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-screenshot'
  gem 'cucumber'
  gem 'cucumber-rails', require: false
  gem 'launchy' # Required to dump the page when running cucumber features
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webmock'
  gem 'webdrivers'
end

group :development do
<<<<<<< HEAD
  gem 'awesome_print'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'capistrano3-unicorn'
  gem 'letter_opener'
=======
  gem 'capistrano3-unicorn'
  gem 'spring'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'unicorn-rails'

>>>>>>> parent of 302f5f47... move config files to puma
  gem 'rails_best_practices'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'unicorn-rails'
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
  gem 'phantomjs'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'spring-commands-teaspoon'
  gem 'teaspoon-jasmine'
  gem 'test-prof'
  gem 'timecop'
end
