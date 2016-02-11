require_relative "./test_es_server"

RSpec.configure do |config|
  config.before(:example, elasticsearch: true) do
    begin
      TestEsServer.start
    rescue Exception => ex
      puts "Failed to start Elasticsearch: #{ex}"
    end
  end
end

at_exit do
  begin
    TestEsServer.stop
  rescue Exception => ex
    puts "Failed to stop Elasticsearch: #{ex}"
  end
end
