require 'rails_helper'

describe Search::Jobs::Artist, elasticsearch: :stub do
  before do
    allow(Search::Indexer::ArtistSearchService).to receive(:new).and_return(indexer_service)
  end

  let(:indexer_service) { instance_double(Search::Indexer::ArtistSearchService, index: true, reindex: true, update: true, remove: true) }

  context 'when the artist exists' do
    let(:artist) { create(:artist) }

    %i[index reindex update remove].each do |method|
      describe ".#{method}" do
        it "runs search #{method} for the artist" do
          described_class.perform_now(artist.id, method)
          expect(Search::Indexer::ArtistSearchService).to have_received(:new).with(artist)
          expect(indexer_service).to have_received(method)
        end
      end
    end
  end

  context 'when we cannot find the artist' do
    it 'does nothing' do
      described_class.perform_now(1_000_000, :index)
      expect(Search::Indexer::ArtistSearchService).not_to have_received(:new)
    end
  end
end
