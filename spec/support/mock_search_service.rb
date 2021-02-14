module MockSearchService
  def stub_query_runner!
    runner = Search::QueryRunner.new('query')
    allow(runner).to receive(:search).and_call_original
    allow(runner).to receive(:multi_index_search).and_return JSON.parse(mock_search_results)
    allow(Search::QueryRunner).to receive(:new).and_return(runner)
  end

  def stub_indexer!
    mock_indexer = double(Search::Indexer::ObjectSearchService)
    allow(mock_indexer).to receive(:index)
    allow(mock_indexer).to receive(:reindex)
    allow(mock_indexer).to receive(:update)
    allow(mock_indexer).to receive(:remove)
    allow(Search::Indexer::ObjectSearchService).to receive(:new).and_return(mock_indexer)
  end

  def stub_search_service!
    stub_query_runner!
    stub_indexer!
  end

  def mock_search_results
    results_json = Rails.root.join 'spec/fixtures/files/search_results.json'
    File.read(File.open(results_json, 'r'))
  end
end

RSpec.configure do |config|
  config.include MockSearchService, type: :feature
  config.include MockSearchService, type: :controller
end
