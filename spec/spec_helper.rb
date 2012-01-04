require 'thread'
require 'rubygems'
ENV['RAILS_ENV'] ||= 'test'
SHARED_REFERER = "/a_referrer_specified_in/spec_helper"

require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'mocha'


require File.expand_path(File.join(File.dirname(__FILE__),'controllers_helper'))
# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # For more information take a look at Spec::Runner::Configuration and Spec::Runner

  config.before(:each, :type => :controller) do
    request.env["HTTP_REFERER"] = SHARED_REFERER
  end

end



require 'mocha'

LETTERS_PLUS_SPACE =  [('a'..'z'),('A'..'Z'), ' '].map{|i| i.to_a}.flatten;
def gen_random_string(len=8)
  numchars = LETTERS_PLUS_SPACE.length
  (0..len).map{ LETTERS_PLUS_SPACE[rand(numchars)] }.join
end
