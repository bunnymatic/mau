require 'rails_helper'

describe Search::Jobs::Studio, elasticsearch: :stub do
  before do
    allow(Search::Indexer::StudioSearchService).to receive(:new).and_return(indexer_service)
  end

  let(:indexer_service) { instance_double(Search::Indexer::StudioSearchService, index: true, reindex: true, update: true, remove: true) }

  context 'when the studio exists' do
    let(:studio) { create(:studio) }

    %i[index reindex update remove].each do |method|
      describe ".#{method}" do
        it "runs search #{method} for the studio" do
          described_class.perform_now(studio.id, method)
          expect(Search::Indexer::StudioSearchService).to have_received(:new).with(studio)
          expect(indexer_service).to have_received(method)
        end
      end
    end
  end

  context 'when we cannot find the studio' do
    it 'does nothing' do
      described_class.perform_now(1_000_000, :index)
      expect(Search::Indexer::StudioSearchService).not_to have_received(:new)
    end
  end
end
