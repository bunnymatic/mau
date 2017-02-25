# frozen_string_literal: true
module MockSearchService
  def stub_query_runner!
    runner = Search::QueryRunner.new('query')
    allow(runner).to receive(:search).and_call_original
    allow(runner).to receive(:multi_index_search).and_return JSON.parse(mock_search_results)
    allow(Search::QueryRunner).to receive(:new).and_return(runner)
  end

  def stub_indexer!
    mockIndexer = double(Search::Indexer::ObjectSearchService)
    allow(mockIndexer).to receive(:index)
    allow(mockIndexer).to receive(:reindex)
    allow(mockIndexer).to receive(:update)
    allow(mockIndexer).to receive(:remove)
    allow(Search::Indexer::ObjectSearchService).to receive(:new).and_return(mockIndexer)
  end

  def stub_search_service!
    stub_query_runner!
    stub_indexer!
  end

  def mock_search_results
    results_json = Rails.root.join 'spec', 'fixtures', 'file', 'search_results.json'
    File.read(File.open(results_json, 'r'))
  end
end

RSpec.configure do |config|
  config.include MockSearchService, type: :feature
  config.include MockSearchService, type: :controller
end
