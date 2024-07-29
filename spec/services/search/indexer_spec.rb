require 'rails_helper'

describe Search::Indexer, search: :none do
  let(:service) { described_class }
  let(:artist) { build_stubbed :artist, :with_art }
  let(:art_piece) { build_stubbed :art_piece }
  let(:studio) { build_stubbed :studio }

  shared_examples_for 'calls the underlying SearchService interface correctly' do
    before do
      allow(search_service_class).to receive(:index)
      allow(search_service_class).to receive(:reindex)
      allow(search_service_class).to receive(:update)
      allow(search_service_class).to receive(:remove)
    end
    describe 'an artist' do
      let(:object) { artist }

      describe '.index' do
        it 'indexes the artist and art pieces' do
          service.index(object)
          expect(search_service_class).to have_received(:index).with(
            object,
          )
        end
        it 'indexes all the artists art pieces' do
          service.index(object)
          object.art_pieces.each do |art|
            expect(search_service_class).to have_received(:index).with(art)
          end
        end
      end
      describe '.reindex' do
        it 'reindexes the artist' do
          service.reindex(object)
          expect(search_service_class).to have_received(:reindex).with(object)
        end
        it 'reindexes all the artists art pieces' do
          service.reindex(object)
          object.art_pieces.each do |art|
            expect(search_service_class).to have_received(:reindex).with(art)
          end
        end
      end
      describe '.update' do
        it 'updates the artist' do
          service.update(object)
          expect(search_service_class).to have_received(:update).with(object)
        end
        it 'updates all the artists art pieces' do
          service.update(object)
          object.art_pieces.each do |art|
            expect(search_service_class).to have_received(:update).with(art)
          end
        end
      end
      describe '.remove' do
        it 'removes the artist' do
          service.remove(object)
          expect(search_service_class).to have_received(:remove).with(object)
        end
        it 'removes all the artists art pieces' do
          service.remove(object)
          object.art_pieces.each do |art|
            expect(search_service_class).to have_received(:remove).with(art)
          end
        end
      end
    end

    describe 'an art_piece' do
      let(:object) { art_piece }

      describe '.index' do
        it 'indexes the art piece document' do
          service.index(object)
          expect(search_service_class).to have_received(:index).with(object)
        end
        fit 'indexes the artist' do
          service.index(object)
          expect(search_service_class).to have_received(:index).with(object.artist)
        end
      end
      describe '.reindex' do
        it 'reindexes the art piece document' do
          service.reindex(object)
          expect(search_service_class).to have_received(:reindex).with(object)
        end
        it 'reindexes the artist' do
          service.reindex(object)
          expect(search_service_class).to have_received(:reindex).with(object.artist)
        end
      end
      describe '.update' do
        it 'updates the art piece document' do
          service.update(object)
          expect(search_service_class).to have_received(:update).with(object)
        end
        it 'updates the artist' do
          service.update(object)
          expect(search_service_class).to have_received(:update).with(object.artist)
        end
      end
      describe '.remove' do
        it 'removes the art piece document' do
          service.remove(object)
          expect(search_service_class).to have_received(:remove).with(object)
        end
      end
    end

    describe 'an studio' do
      let(:object) { studio }

      describe '.index' do
        it 'indexes the studio' do
          service.index(object)
          expect(search_service_class).to have_received(:index).with(object)
        end
      end
      describe '.reindex' do
        it 'reindexes the studio' do
          service.reindex(object)
          expect(search_service_class).to have_received(:reindex).with(object)
        end
      end
      describe '.update' do
        it 'updates the studio' do
          service.update(object)
          expect(search_service_class).to have_received(:update).with(object)
        end
      end
      describe '.remove' do
        it 'removes the studio' do
          service.remove(object)
          expect(search_service_class).to have_received(:remove).with(object)
        end
      end
    end
  end

  context 'when we use elasticsearch' do
    before do
      allow(FeatureFlags).to receive(:use_open_search?).and_return false
    end
    let(:search_service_class) { Search::Elasticsearch::SearchService }
    it_behaves_like 'calls the underlying SearchService interface correctly'
  end

  context 'when we use open search' do
    before do
      allow(FeatureFlags).to receive(:use_open_search?).and_return true
    end
    let(:search_service_class) { Search::OpenSearch::SearchService }
    it_behaves_like 'calls the underlying SearchService interface correctly'
  end
end
