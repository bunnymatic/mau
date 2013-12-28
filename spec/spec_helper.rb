# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
# Writes the coverage stat to a file to be used by Cane.
class SimpleCov::Formatter::QualityFormatter
  def format(result)
    SimpleCov::Formatter::HTMLFormatter.new.format(result)
    File.open('coverage/covered_percent', 'w') do |f|
      f.puts result.source_files.covered_percent.to_f
    end
  end
end
SimpleCov.formatter = SimpleCov::Formatter::QualityFormatter

SimpleCov.start 'rails' do
  add_filter "/lib/restful_authentication/"
  add_filter '/config/'
  add_filter '/vendor/'
  add_group  'Models', 'app/models'
  add_group  'Presenters', 'app/presenters'
  add_group  'Validators', 'app/validators'
  add_group  'Controllers', 'app/controllers'
  add_group  'Helpers', 'app/helpers'
  add_group  'Mailers', 'app/mailers'
end

SHARED_REFERER = "/a_referrer_specified_in/spec_helper" unless defined? SHARED_REFERER

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/factories/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"


  config.before(:each, :type => :controller) do
    request.env["HTTP_REFERER"] = SHARED_REFERER
  end

end
