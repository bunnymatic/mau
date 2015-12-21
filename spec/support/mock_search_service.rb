module MockSearchService
  def stub_search_service!
    runner = Search::QueryRunner.new('query')
    allow(runner).to receive(:search).and_call_original
    allow(runner).to receive(:multi_index_search).and_return JSON.parse(mock_search_results)
    allow(Search::QueryRunner).to receive(:new).and_return( runner )
  end

  def mock_search_results
    File.read(File.open(File.join(Rails.root, 'spec','fixtures','files/search_results.json'),'r'))
  end
end

RSpec.configure do |config|
  config.include MockSearchService, type: :feature
  config.include MockSearchService, type: :controller
end
