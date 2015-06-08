source 'https://rubygems.org'
ruby '2.1.5'

gem 'safe_yaml'
gem 'racc'
gem "rails", '~> 3.2.16'
gem 'strong_parameters'
gem "font-awesome-rails"
# gem 'aasm'
gem "nokogiri", '~> 1.6'
gem "htmlentities"
gem 'mysql2'
gem "haml"
gem "slim-rails"
gem 'mojo_magick'
gem 'dalli'
gem 'hashie'
gem 'rdiscount' # markdown processor
gem 'capistrano', '~> 3.1.0'
gem 'capistrano-rbenv', '~> 2.0'
gem 'capistrano-rails', '~> 1.1'
gem 'friendly_id', '~> 4.x'
gem 'formtastic', '~> 3.0'

gem 'gibbon' # mailchimp connect
gem 'rosie'
gem 'grackle'
gem 'mime-types'
gem 'qr4r'
gem 'event-calendar', :require => 'event_calendar'
gem 'rack-cors', :require => 'rack/cors'
gem 'momentarily'
gem 'faye'
gem "recaptcha", :require => "recaptcha/rails"
gem 'will_paginate'
gem 'browser'
gem 'geokit'
gem 'geokit-rails'
gem 'gmaps4rails'
gem 'pickadate-rails'
gem 'draper'
gem 'spinjs-rails'
gem 'paperclip'
gem 'aws-sdk-v1'

source 'https://rails-assets.org' do
  gem 'rails-assets-angular'
  gem 'rails-assets-angular-resource'
  gem 'rails-assets-angular-sanitize'
  gem 'rails-assets-angular-animate'
  gem 'rails-assets-angular-ui-utils'
  gem 'rails-assets-moment'
  gem 'rails-assets-lodash'
  gem 'rails-assets-colorbox' # lightbox plugin
  gem 'rails-assets-jquery'
  gem 'rails-assets-jquery-ujs'
  gem 'rails-assets-pure'
  gem 'rails-assets-ngDialog'
  gem 'rails-assets-angular-mailchimp'
  gem 'rails-assets-re-tree'
  gem 'rails-assets-ng-device-detector'
  gem 'rails-assets-datatables'
end
gem 'ngannotate-rails'
gem 'angular-rails-templates'

# authentication
gem 'authlogic'

# mailing with postmarkapp.com
gem 'postmark-rails'
gem 'postmark'

gem 'newrelic_rpm'

gem 'unicorn'

gem 'flot-rails' # jquery plotting program

gem 'select2-rails' # autocompleter

gem 'underscore-string-rails'

gem 'multi_json'
gem 'jbuilder'

gem 'skylight'

group :test do
  gem 'faker'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl'
  gem 'factory_girl_rails', :require => false
  gem 'cucumber'
  gem 'cucumber-rails', :require => false
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  gem 'poltergeist'
  gem 'launchy'             # Required to dump the page when running cucumber features
end

group :assets, :development do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'libv8'
  gem 'uglifier'
end

group :development do
  gem 'annotate'
  #gem 'capistrano-nginx-unicorn', require: false, group: :development
  gem 'capistrano3-unicorn'
  gem 'spring'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'unicorn-rails'

  gem 'rails_best_practices'
end

group :test, :development do
  gem 'guard-coffeescript'
  gem 'guard-rspec'
  gem 'guard-jasmine'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'em-rspec', :require => false, :git => 'https://github.com/jwroblewski/em-rspec.git'
  gem 'jslint_on_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rb-fsevent'
  gem 'simplecov'
  gem 'cane'
  gem 'morecane'
  gem 'guard-cucumber'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'quiet_assets'
  gem 'jasminerice', github: 'bradphelan/jasminerice'
  gem 'timecop'
end
