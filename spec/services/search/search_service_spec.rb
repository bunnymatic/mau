require 'rails_helper'

describe Search::Indexer do

  subject(:service) { Search::Indexer }
  let(:artist) { create :artist, :with_art }
  let(:art_piece) { artist.art_pieces.first }
  let(:studio) { create :studio }

  ES_METHODS = {
    index_document: nil,
    delete_document: nil,
    update_document: nil
  }

  describe 'an artist' do
    let(:object) { artist }
    before do
      ES_METHODS.keys.each do |method|
        allow(object.__elasticsearch__).to receive method
        object.art_pieces.each do |art|
          allow(art.__elasticsearch__).to receive method
        end
      end
    end
    describe '.index' do
      it 'indexes the artist' do
        expect(object.__elasticsearch__).to receive(:index_document)
        service.index(object)
      end
      it 'indexes all the artists art pieces' do
        object.art_pieces.each do |art|
          expect(art.__elasticsearch__).to receive(:index_document)
        end
        service.index(object)
      end
    end
    describe '.reindex' do
      it 'reindexes the artist' do
        expect(object.__elasticsearch__).to receive(:delete_document)
        expect(object.__elasticsearch__).to receive(:index_document)
        service.reindex(object)
      end
      it 'reindexes all the artists art pieces' do
        object.art_pieces.each do |art|
          expect(art.__elasticsearch__).to receive(:delete_document)
          expect(art.__elasticsearch__).to receive(:index_document)
        end
        service.reindex(object)
      end
    end
    describe '.update' do
      it 'updates the artist' do
        expect(object.__elasticsearch__).to receive(:update_document)
        service.update(object)
      end
      it 'updates all the artists art pieces' do
        object.art_pieces.each do |art|
          expect(art.__elasticsearch__).to receive(:update_document)
        end
        service.update(object)
      end
    end
    describe '.remove' do
      it 'removes the artist' do
        expect(object.__elasticsearch__).to receive(:delete_document)
        service.remove(object)
      end
      it 'removes all the artists art pieces' do
        object.art_pieces.each do |art|
          expect(art.__elasticsearch__).to receive(:delete_document)
        end
        service.remove(object)
      end
    end
  end

  describe 'an art_piece' do
    let(:object) { art_piece }
    before do
      ES_METHODS.keys.each do |method|
        allow(object.__elasticsearch__).to receive method
        allow(object.artist.__elasticsearch__).to receive method
      end
    end

    describe '.index' do
      it 'indexes the art piece document' do
        expect(object.__elasticsearch__).to receive(:index_document)
        service.index(object)
      end
      it 'indexes all the artists art pieces' do
        expect(object.artist.__elasticsearch__).to receive(:index_document)
        service.index(object)
      end
    end
    describe '.reindex' do
      it 'reindexes the art piece document' do
        expect(object.__elasticsearch__).to receive(:delete_document)
        expect(object.__elasticsearch__).to receive(:index_document)
        service.reindex(object)
      end
      it 'reindexes all the artists art pieces' do
        expect(object.artist.__elasticsearch__).to receive(:delete_document)
        expect(object.artist.__elasticsearch__).to receive(:index_document)
        service.reindex(object)
      end
    end
    describe '.update' do
      it 'updates the art piece document' do
        expect(object.__elasticsearch__).to receive(:update_document)
        service.update(object)
      end
      it 'updates all the artists art pieces' do
        expect(object.artist.__elasticsearch__).to receive(:update_document)
        service.update(object)
      end
    end
    describe '.remove' do
      it 'removes the art piece document' do
        expect(object.__elasticsearch__).to receive(:delete_document)
        service.remove(object)
      end
    end

  end

  describe 'an studio' do
    let(:object) { studio }
    describe '.index' do
      it 'indexes the studio' do
        expect(object.__elasticsearch__).to receive(:index_document)
        service.index(object)
      end
    end
    describe '.reindex' do
      it 'reindexes the studio' do
        expect(object.__elasticsearch__).to receive(:delete_document)
        expect(object.__elasticsearch__).to receive(:index_document)
        service.reindex(object)
      end
    end
    describe '.update' do
      it 'updates the studio' do
        expect(object.__elasticsearch__).to receive(:update_document)
        service.update(object)
      end
    end
    describe '.remove' do
      it 'removes the studio' do
        expect(object.__elasticsearch__).to receive(:delete_document)
        service.remove(object)
      end
    end
  end

end
