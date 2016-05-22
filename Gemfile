source 'https://rubygems.org'
ruby '2.3.1'

gem 'rake'
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

gem 'dotenv-rails'

gem 'sass-rails'
gem 'coffee-rails'
# uglifier 2.7.2 breaks Angular in feature specs on CI. Connecting to CircleCI over VNC
# (https://circleci.com/docs/browser-debugging#interact-with-the-browser-over-vnc)
# shows the error: "[$injector:unpr] Unknown provider: tProvider <- t <- $http <- $templateRequest <- $compile"
# The changelog for `uglifier` shows an upgrade from UglifyJS2 2.4.16 to 2.4.24,
# (https://github.com/mishoo/UglifyJS2/compare/v2.4.16...v2.4.24)
# but I couldn't find a changelog for that to help figure out why it breaks our minification
gem 'uglifier'

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

  gem 'guard-rspec'
  gem 'rb-fsevent'
  gem "elasticsearch-extensions", require: nil


  gem 'simplecov'
  gem 'cane'
  gem 'morecane'
  gem 'quiet_assets'

  gem 'jslint_on_rails'
  gem 'pry-byebug'
end
