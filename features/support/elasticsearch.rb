require_relative '../../spec/support/test_search_server'
require_relative 'webmock'

BeforeAll do
  TestSearchServer.start unless ENV['CI']
end

at_exit do
  TestSearchServer.stop unless ENV['CI']
rescue Exception => e
  puts "Failed to stop search server #{e}"
end
