source 'https://rubygems.org'
ruby '2.1.2'

gem 'racc'
gem "rails", '~> 3.2.16'
gem 'font-awesome-rails'
# gem 'aasm'
gem "nokogiri", '~> 1.6'
gem "htmlentities"
gem "json"
gem 'mysql2'
gem "haml"
gem 'mojo_magick'
gem 'dalli'
gem 'hashie'
gem 'tzinfo'
gem 'rdiscount' # markdown processor
gem 'mobile-fu', github: 'rcode5/mobile-fu'
gem 'capistrano', '~> 3.1.0'
gem 'capistrano-rbenv', '~> 2.0'
gem 'capistrano-rails', '~> 1.1'

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
gem 'angularjs-rails'

# authentication
gem 'authlogic'

# mailing with postmarkapp.com
gem 'postmark-rails'
gem 'postmark'

gem 'jquery-rails'
gem 'jquery_mobile_rails'

gem 'newrelic_rpm'

gem 'unicorn'

gem 'flot-rails' # jquery plotting program

gem 'colorbox-rails' # lightbox plugin

gem 'select2-rails' # autocompleter

gem 'underscore-rails'
gem 'underscore-string-rails'

gem 'multi_json'

gem 'skylight'

group :test do
  gem 'faker'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl'
  gem 'factory_girl_rails', :require => false
  gem 'cucumber'
  gem 'cucumber-rails', :require => false
  gem 'poltergeist'
  gem 'launchy'             # Required to dump the page when running cucumber features
end

group :assets,:development do
  gem 'coffee-rails'
  gem 'sass-rails'
  gem 'libv8'
end

group :development do
  gem 'annotate'
  #gem 'capistrano-nginx-unicorn', require: false, group: :development
  gem 'capistrano3-unicorn'
  gem 'thin'
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
  gem 'rb-fsevent'
  gem 'simplecov'
  gem 'cane'
  gem 'morecane'
  gem 'guard-cucumber'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'quiet_assets'
  gem 'jasminerice', github: 'bradphelan/jasminerice' 
#  gem 'better_errors'
#  gem "binding_of_caller"

  gem 'rails_best_practices'
end
