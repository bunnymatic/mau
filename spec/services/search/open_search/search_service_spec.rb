require 'rails_helper'

describe Search::OpenSearch::SearchService do
  before do
    allow(Search::OpenSearchClient).to receive(:delete)
    allow(Search::OpenSearchClient).to receive(:index)
    allow(Search::OpenSearchClient).to receive(:update)
    allow(Search::OpenSearchClient).to receive(:multi_index_search)
    allow(Search::OpenSearchClient).to receive(:create_index)
    allow(Search::OpenSearchClient).to receive(:delete_index)
  end

  let(:artist) { create(:artist, :with_art) }

  describe '.index' do
    it 'indexes the object' do
      described_class.index(artist)
      expect(Search::OpenSearchClient).to have_received(:index)
    end
    it 'does nothing if the object has no info' do
      described_class.index(build(:artist))
      expect(Search::OpenSearchClient).not_to have_received(:index)
    end
  end

  describe '.reindex' do
    it 'deletes and reads the object to the index' do
      described_class.reindex(artist)
      expect(Search::OpenSearchClient).to have_received(:delete).with(
        'artists', artist.id
      )
      expect(Search::OpenSearchClient).to have_received(:index).with(
        'artists', artist.id, artist.as_indexed_json
      )
    end
    it 'does nothing if the object has no info' do
      described_class.index(build(:artist))
      expect(Search::OpenSearchClient).not_to have_received(:delete)
      expect(Search::OpenSearchClient).not_to have_received(:index)
    end
  end

  describe '.remove' do
    let(:artist) { build(:artist, id: 123) }
    it 'removes the object from the instance' do
      described_class.remove(artist)
      expect(Search::OpenSearchClient).to have_received(:delete).with(
        'artists', artist.id
      )
    end
  end

  describe '.update' do
    it 'udpates object in the index' do
      described_class.update(artist)
      expect(Search::OpenSearchClient).to have_received(:update).with(
        'artists', artist.id, artist.as_indexed_json
      )
    end
    it 'does nothing if the object has no info' do
      described_class.update(build(:artist))
      expect(Search::OpenSearchClient).not_to have_received(:update)
    end
  end

  describe '.reindex_all' do
    let(:art_piece) { create(:art_piece) }
    before do
      art_piece
    end
    it 'reindexes all objects for the class' do
      described_class.reindex_all(ArtPiece)

      expect(Search::OpenSearchClient).to have_received(:delete).with('art_pieces', art_piece.id)
      expect(Search::OpenSearchClient).to have_received(:index).with(
        'art_pieces',
        art_piece.id,
        art_piece.as_indexed_json,
      )
    end
  end

  describe '.create_index' do
    it 'creates the index' do
      described_class.create_index(Studio)
      expect(Search::OpenSearchClient).to have_received(:create_index).with(
        'studios',
        settings: Search::Indexer::INDEX_SETTINGS,
        analysis: Search::Indexer::ANALYZERS_TOKENIZERS,
        mappings: Search::SearchableObject.mappings_by_object_type(Studio),
      )
    end
  end

  describe '.delete_index' do
    it 'deletes the index' do
      described_class.delete_index(Artist)
      expect(Search::OpenSearchClient).to have_received(:delete_index).with('artists')
    end
  end

  describe '.search' do
    it 'calls the search endpoint' do
      described_class.search('leonardo da vi')
      expect(Search::OpenSearchClient).to have_received(:multi_index_search).with(
        an_array_matching(%w[artists art_pieces studios]),
        {
          query: {
            multi_match: {
              query: 'leonardo da vi',
              fields: Search::Indexer::MULTI_MATCH_QUERY_FIELDS,
              type: 'most_fields',
              fuzziness: 0,
            },
          },
          size: 100,
        },
      )
    end
  end
end
