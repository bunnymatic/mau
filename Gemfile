source 'https://rubygems.org'
ruby '2.3.1'

gem 'racc'
gem "rails", '~> 4.2'
gem 'active_model_serializers'
gem 'responders'
gem 'lograge'
gem "font-awesome-rails"
gem "nokogiri"
gem "htmlentities"
gem 'mysql2', '~> 0.4.x'
gem "haml"
gem "slim-rails"
gem 'mojo_magick'
gem 'dalli'
gem 'hashie'
gem 'rdiscount' # markdown processor
gem 'capistrano'
gem 'capistrano-rbenv'
gem 'capistrano-rails'
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
gem 'aws-sdk'

gem 'ngannotate-rails'
gem 'angular-rails-templates'

# authentication
gem 'authlogic'

# mailing with postmarkapp.com
gem 'postmark-rails'
gem 'postmark'

gem 'unicorn' # webserver

gem 'select2-rails' # autocompleter

gem 'jbuilder' #non-html output (rss, atom)

gem 'newrelic_rpm' #moitoring

gem 'dotenv-rails'

gem 'sass-rails'
gem 'autoprefixer-rails'
gem 'coffee-rails'

gem 'uglifier'

gem 'actionmailer-text'

source 'https://rails-assets.org' do
  gem 'rails-assets-angular', "=1.3.16"
  gem 'rails-assets-angular-resource', "=1.3.16"
  gem 'rails-assets-angular-sanitize', "=1.3.16"
  gem 'rails-assets-angular-animate', "=1.3.16"
  gem 'rails-assets-angular-ui-utils', "~> 0.2.3"
  gem 'rails-assets-angular-mocks'
  gem 'rails-assets-angular-moment'
  gem 'rails-assets-moment'
  gem 'rails-assets-lodash'
  gem 'rails-assets-pure'
  gem 'rails-assets-ngDialog'
  gem 'rails-assets-angular-mailchimp'
  gem 'rails-assets-re-tree'             # required for device-detector
  gem 'rails-assets-ng-device-detector'
  gem 'rails-assets-datatables'
  gem 'rails-assets-spinjs'
  gem 'rails-assets-flot'
end

group :test do
  gem 'faker'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl', require: false
  gem 'factory_girl_rails', require: false
  gem 'cucumber'
  gem 'cucumber-rails', require: false
  gem 'poltergeist'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'launchy'             # Required to dump the page when running cucumber features
end

group :development do
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
  gem 'timecop'
  gem 'database_cleaner'
  gem 'shoulda-matchers'

  gem 'teaspoon-jasmine'
  gem 'spring-commands-teaspoon'

  gem "elasticsearch-extensions", require: nil

  gem 'simplecov'
  gem 'cane'
  gem 'morecane'
  gem 'quiet_assets'

  gem 'jslint_on_rails'
  gem 'pry-byebug'
end
