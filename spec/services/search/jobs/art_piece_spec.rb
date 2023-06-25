require 'rails_helper'

describe Search::Jobs::ArtPiece, elasticsearch: :stub do
  before do
    allow(Search::Indexer::ArtPieceSearchService).to receive(:new).and_return(indexer_service)
  end

  let(:indexer_service) { instance_double(Search::Indexer::ArtPieceSearchService, index: true, reindex: true, update: true, remove: true) }

  context 'when the art_piece exists' do
    let(:art_piece) { create(:art_piece) }

    %i[index reindex update remove].each do |method|
      describe ".#{method}" do
        it "runs search #{method} for the art_piece" do
          described_class.perform_now(art_piece.id, method)
          expect(Search::Indexer::ArtPieceSearchService).to have_received(:new).with(art_piece)
          expect(indexer_service).to have_received(method)
        end
      end
    end
  end

  context 'when we cannot find the art_piece' do
    it 'does nothing' do
      described_class.perform_now(1_000_000, :index)
      expect(Search::Indexer::ArtPieceSearchService).not_to have_received(:new)
    end
  end
end
