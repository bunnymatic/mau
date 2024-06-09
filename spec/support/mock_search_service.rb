module MockSearchService
  def stub_query_runner!
    runner = Search::QueryRunner.new('query')
    allow(runner).to receive(:search).and_return JSON.parse(mock_search_results)
    allow(Search::QueryRunner).to receive(:new).and_return(runner)
  end

  def stub_indexer!
    allow(Search::SearchService).to receive(:index)
    allow(Search::SearchService).to receive(:reindex)
    allow(Search::SearchService).to receive(:update)
    allow(Search::SearchService).to receive(:remove)
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
