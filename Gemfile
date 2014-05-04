source 'https://rubygems.org'
ruby '2.1.1'

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
gem 'geokit-rails'
gem 'gmaps4rails'
gem 'pickadate-rails'
gem 'draper'
gem 'spinjs-rails'
gem 'angularjs-rails'

# mailing with postmarkapp.com
gem 'postmark-rails'
gem 'postmark'

gem 'jquery-rails'

gem 'newrelic_rpm'

gem 'unicorn'

gem 'flot-rails' # jquery plotting program

gem 'colorbox-rails' # lightbox plugin

gem 'select2-rails' # autocompleter

gem 'underscore-rails'
gem 'underscore-string-rails'

gem 'oj'

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
  gem 'guard-rspec' # , '~> 1.2.0'  # 1.2.x is order rspec compatible
  gem 'guard-jasmine'
  gem 'rspec' #,'1.3.1'
  gem 'rspec-rails' #,'1.3.4'
  gem 'em-rspec', :require => false, :git => 'https://github.com/jwroblewski/em-rspec.git'
  gem 'jslint_on_rails'
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
#  gem 'better_errors'
#  gem "binding_of_caller"
  gem 'jasminerice'
end
