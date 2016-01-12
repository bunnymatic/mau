source 'https://rubygems.org'
ruby '2.1.5'

gem 'racc'
gem "rails", '~> 4.2'
gem 'active_model_serializers'
gem 'responders'
gem "font-awesome-rails"
gem "nokogiri"
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
gem 'friendly_id'
gem 'formtastic'

gem 'elasticsearch-model'
gem 'elasticsearch-rails'

gem 'gibbon' # mailchimp connect
gem 'rosie'

gem 'mime-types'
gem 'qr4r'
gem 'rack-cors', require: 'rack/cors'
gem "recaptcha", require: "recaptcha/rails"
gem 'browser'
gem 'geokit'
gem 'geokit-rails'
gem 'gmaps4rails'
gem 'pickadate-rails'
gem 'paperclip'
gem 'aws-sdk-v1'

gem 'ngannotate-rails'
gem 'angular-rails-templates'

# authentication
gem 'authlogic'

# mailing with postmarkapp.com
gem 'postmark-rails'
gem 'postmark'

gem 'unicorn' # webserver

gem 'flot-rails' # jquery plotting program

gem 'select2-rails' # autocompleter

gem 'underscore-string-rails'

gem 'jbuilder' #non-html output (rss, atom)

gem 'newrelic_rpm' #moitoring

gem 'dotenv'

source 'https://rails-assets.org' do
  gem 'rails-assets-angular', "=1.3.16"
  gem 'rails-assets-angular-resource', "=1.3.16"
  gem 'rails-assets-angular-sanitize', "=1.3.16"
  gem 'rails-assets-angular-animate', "=1.3.16"
  gem 'rails-assets-angular-ui-utils', "~> 0.2.3"
  gem 'rails-assets-angular-mocks'
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
  gem 'rails-assets-spinjs'
end

group :test do
  gem 'faker'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl', require: false
  gem 'factory_girl_rails', require: false
  gem 'cucumber'
  gem 'cucumber-rails', require: false
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
  gem 'therubyracer'
end

group :development do
  gem 'annotate'
  gem 'capistrano3-unicorn'
  gem 'spring'
  gem 'better_errors'
  gem "binding_of_caller"
  gem 'unicorn-rails'

  gem 'rails_best_practices'
end

group :test, :development do
  gem 'rspec'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails'
  gem 'em-rspec', require: false, git: 'https://github.com/jwroblewski/em-rspec.git'
  gem 'jasminerice', github: 'bradphelan/jasminerice'
  gem 'timecop'
  gem 'database_cleaner'
  gem 'shoulda-matchers'

  gem 'guard-rspec'
  gem 'guard-jasmine'
  gem 'guard-cucumber'
  gem 'rb-fsevent'
  gem "elasticsearch-extensions", require: nil


  gem 'simplecov'
  gem 'cane'
  gem 'morecane'
  gem 'quiet_assets'

  gem 'jslint_on_rails'
  gem 'pry-byebug'
end
