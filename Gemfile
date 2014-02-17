source 'https://rubygems.org'
ruby '2.0.0'

gem 'racc'
gem "rails", '~> 3.2.16'
gem 'aasm'
gem "nokogiri" #, '~> 1.5.0' # 1.6.0 needs ruby 1.9.2
gem "htmlentities"
gem "json"
gem 'mysql2'
gem "haml"
gem 'mojo_magick'
gem 'dalli'
gem 'hashie'
gem 'tzinfo'
gem 'rdiscount' # markdown processor
gem 'mobile-fu'
gem 'capistrano', '~> 3.1.0'
gem 'capistrano-rbenv', '~> 2.0'
gem 'capistrano-rails', '~> 1.1'

gem 'gibbon', '~> 0.3.5' # mailchimp connect
gem 'calendar_date_select'
gem 'rosie'
gem 'grackle'
gem 'mime-types'
gem 'qr4r'
gem 'event-calendar', :require => 'event_calendar'
gem 'rack-cors', :require => 'rack/cors'
gem 'momentarily'
gem 'faye'
gem "recaptcha", :require => "recaptcha/rails"
gem 'will_paginate' #, '~> 2.3.16'
gem 'browser', "= 0.1.6" # 0.2.x does not support ruby 1.8.7
gem 'geokit'
#gem 'geokit-rails'
gem 'geokit-rails3'
gem 'gmaps4rails'
gem 'pickadate-rails'
gem 'draper'

# mailing with postmarkapp.com
gem 'postmark-rails'
gem 'postmark'

gem 'jquery-rails'

gem 'newrelic_rpm'

group :test do
  gem 'faker'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl', '~> 2.0.x'
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

group :test, :development do
  gem 'annotate'
  gem 'guard-coffeescript'
  gem 'guard-rspec', '~> 1.2.0'  # 1.2.x is order rspec compatible
  gem 'rspec' #,'1.3.1'
  gem 'rspec-rails' #,'1.3.4'
  gem 'jslint_on_rails'
  gem 'jasmine'
  gem 'pry'
  gem 'pry-debugger'
  gem 'rb-fsevent' #, '~> 0.9.1' # for guard
  gem 'simplecov'
  gem 'cane'
  gem 'morecane'
  gem 'rails_best_practices'
  gem 'guard-cucumber'
  gem 'database_cleaner'
  gem 'shoulda-matchers'
  gem 'quiet_assets'
  gem 'em-rspec', :git => 'https://github.com/rcode5/em-rspec.git'
end
