require 'thread'
require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'
SHARED_REFERER = "/a_referrer_specified_in/spec_helper" unless defined? SHARED_REFERER

require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
#require 'rspec/autorun'
require 'rspec/rails'

require 'fakeweb'
puts "FakeWeb is on ---- no outside requests will be allowed!"
FakeWeb.allow_net_connect = false

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
  config.fixture_path = File.join(Rails.root, 'spec', 'fixtures')

  config.mock_with :rspec
  # config.mock_with :flexmock
  # config.mock_with :rr

  # For more information take a look at Spec::Runner::Mau::Application.config.guration and Spec::Runner

  config.before(:each, :type => :controller) do
    request.env["HTTP_REFERER"] = SHARED_REFERER
  end

end

LETTERS_PLUS_SPACE =  []
('a'..'z').each {|ltr| LETTERS_PLUS_SPACE << ltr}
('A'..'Z').each {|ltr| LETTERS_PLUS_SPACE << ltr}

def gen_random_string(len=8)
  numchars = LETTERS_PLUS_SPACE.length
  (0..len).map{ LETTERS_PLUS_SPACE[rand(numchars)] }.join
end

def gen_random_words *args
  opts = {:min_length => 1, :min_words => 2}
  if args.empty?
    opts.merge!({:min_length => 15})
  else
    args.each do |arg|
      opts.merge! arg
    end
  end
  min_length = opts[:min_length]
  min_words = opts[:min_words]
  words = []

  while words.empty? || ((words.length < min_words) || ((words.length > 1) && (words.map(&:length).sum < min_length)))
    words << gen_random_string( 3 + rand(6) )
  end
  words.join(' ')
end
