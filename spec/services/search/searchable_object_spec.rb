require 'rails_helper'

describe Search::SearchableObject do
  describe '.index_by_object_type' do
    it 'returns the name as the class underscored and pluralized' do
      expect(described_class.index_by_object_type(Artist)).to eq 'artists'
      expect(described_class.index_by_object_type(ArtPiece)).to eq 'art_pieces'
      expect(described_class.index_by_object_type(Studio)).to eq 'studios'
    end
    it 'raises if you try with a class that we know is not an index' do
      expect { described_class.index_by_object_type(Hash) }.to raise_error(described_class::NotSearchableObject, /hashes is not included/)
    end
  end

  describe '.mappings_by_object_type' do
    it 'returns mappings for artists' do
      expect(described_class.mappings_by_object_type(Artist)).to eq(
        {
          'artist' => {
            properties: {
              artist_name: { type: 'text', analyzer: :mau_ngram_analyzer },
              firstname: { type: 'text', analyzer: :mau_ngram_analyzer },
              lastname: { type: 'text', analyzer: :mau_ngram_analyzer },
              nomdeplume: { type: 'text', analyzer: :mau_ngram_analyzer },
              studio_name: { type: 'text', analyzer: :mau_ngram_analyzer },
              bio: { type: 'text', index: false },
            },
          },
        },
      )
    end
    it 'returns mappings for art_pieces' do
      expect(described_class.mappings_by_object_type(ArtPiece)).to eq(
        {
          'art_piece' => {
            properties: {
              title: { type: 'text', analyzer: 'english' },
              title_ngram: {
                type: 'text', analyzer: :mau_ngram_analyzer
              },
              year: { type: 'text' },
              medium: {
                type: 'text', analyzer: 'english'
              },
              artist_name: {
                type: 'text', analyzer: :mau_ngram_analyzer
              },
              studio_name: {
                type: 'text', analyzer: :mau_ngram_analyzer
              },
              tags: {
                type: 'text', analyzer: 'english'
              },
            },
          },

        },
      )
    end
    it 'returns mappings for studios' do
      expect(described_class.mappings_by_object_type(Studio)).to eq(
        {
          'studio' => {
            properties: {
              name: { type: 'text', analyzer: :mau_ngram_analyzer },
              address: { type: 'text', analyzer: :mau_ngram_analyzer },
            },
          },
        },
      )
    end
    it 'returns nothing for a document type we don\'t have' do
      expect(described_class.mappings_by_object_type(Hash)).to eq({})
    end
  end

  describe '#index_name' do
    it 'returns the name as the class underscored and pluralized' do
      expect(described_class.new(Artist.new).index_name).to eq 'artists'
      expect(described_class.new(ArtPiece.new).index_name).to eq 'art_pieces'
      expect(described_class.new(Studio.new).index_name).to eq 'studios'
    end
    it 'raises if you try with a class that we know is not an index' do
      expect { described_class.new({}).index_name }.to raise_error(described_class::NotSearchableObject, /hashes is not included/)
    end
  end

  describe '#document_type' do
    it 'returns the name as the class underscored and pluralized' do
      expect(described_class.new(Artist.new).document_type).to eq 'artist'
      expect(described_class.new(ArtPiece.new).document_type).to eq 'art_piece'
      expect(described_class.new(Studio.new).document_type).to eq 'studio'
    end
  end

  describe '#document' do
    let(:artist) { build(:artist) }
    let(:art_piece) { build(:art_piece) }
    let(:studio) { build(:studio) }

    it 'returns the document as json' do
      expect(described_class.new(artist).document).to eq artist.as_indexed_json
      expect(described_class.new(art_piece).document).to eq art_piece.as_indexed_json
      expect(described_class.new(studio).document).to eq studio.as_indexed_json
    end
  end
end
