require_relative "./test_es_server"

RSpec.configure do |config|
  config.before do |example|
    if (example.metadata[:elasticsearch])
      begin
        TestEsServer.start
      rescue Exception => ex
        puts "Failed to start Elasticsearch: #{ex}"
      end
    else
      # stub elastic search calls
      allow(Search::Indexer).to receive(:index)
      allow(Search::Indexer).to receive(:remove)
      allow(Search::Indexer).to receive(:reindex)
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
