source 'https://rubygems.org'

gem 'racc'
gem "rails", '~> 3.0.20'
gem "geokit"
gem "geokit-rails"
gem "nokogiri", '~> 1.5.0' # 1.6.0 needs ruby 1.9.2
gem "htmlentities"
gem "json"
gem 'mysql2', '~>0.2.11'
gem 'activerecord-mysql2-adapter'
gem "haml"
gem "sass"
gem 'mojo_magick'
gem 'dalli'
gem 'memcache-client'
gem 'hashie'
gem 'tzinfo'
gem 'rdiscount' # markdown processor
gem 'mobile_fu-rails3'
gem 'fastercsv'
gem 'capistrano'
gem 'rvm-capistrano'
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
#gem 'rails_xss' # get us closer to Rails3 behavior by auto html escaping
#gem 'erubis' # for rails_xss

#gem 'pdfkit'
#gem 'wicked_pdf'
#gem 'wkhtmltopdf-binary'

# mailing with postmarkapp.com
gem 'postmark-rails'
gem 'postmark'
gem 'tmail'

group :staging, :production do
  gem 'newrelic_rpm'
end

group :test, :development do
  gem 'guard-coffeescript'
  gem 'guard-rspec', '~> 1.2.0'  # 1.2.x is order rspec compatible
  gem 'rspec' #,'1.3.1'
  gem 'rspec-rails' #,'1.3.4'
  gem 'faker'
  gem 'jslint_on_rails'
  gem 'fakeweb'
  gem 'factory_girl', '~> 2.0.x'
  gem 'jasmine'
  gem 'jasmine-headless-webkit'
  gem 'pry'
  gem 'ruby-debug'
  gem 'rb-fsevent' #, '~> 0.9.1' # for guard
  gem "rcov_rails"
  # gem 'rails-upgrade'
end
