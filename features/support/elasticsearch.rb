require_relative '../../spec/support/test_es_server'
require_relative './webmock'

BeforeAll do
  TestEsServer.start unless ENV['CI']
end

at_exit do
  TestEsServer.stop unless ENV['CI']
rescue Exception => e
  puts "Failed to stop Elasticsearch: #{e}"
end
