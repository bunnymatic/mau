require 'rails_helper'

describe ArtPieceTagService do
  let(:service) { described_class }

  before do
    Rails.cache.clear
  end

  describe '.tags_sorted_by_frequency' do
    let!(:art_pieces) { create_list :art_piece, 6, :with_tags }
    let!(:tags) { FactoryBot.create_list :art_piece_tag, 5 }
    let!(:extra_tags) { FactoryBot.create_list :art_piece_tag, 2 }
    before do
      art_pieces.each_with_index do |ap, idx|
        ap.tags = tags[0..(5 - idx)]
        ap.save!
      end
    end

    it 'returns tags with their count' do
      freq = service.tags_sorted_by_frequency
      expect(freq.first.frequency).to eq 6
      expect(freq.last.frequency).to eq 2
    end
  end

  describe '.most_popular_tag' do
    let(:art_pieces) { create_list :art_piece, 3 }
    let(:tags) do
      [
        create(:art_piece_tag, name: 'hello'),
        create(:art_piece_tag, name: 'hello a'),
      ]
    end
    before do
      art_pieces.each_with_index do |ap, idx|
        ap.tags = tags[0..(2 - idx)]
        ap.save!
      end
    end
    it 'returns most popular tag by frequency and medium' do
      expect(described_class.most_popular_tag).to eql(ArtPieceTag.find('hello'))
    end
  end

  describe '.delete_unused_tags' do
    it 'removes only tags that are unused' do
      create :art_piece, :with_tag
      FactoryBot.create_list :art_piece_tag, 5
      expect do
        service.delete_unused_tags
        expect(service.tags_sorted_by_frequency.to_a.size).to eq 1
      end.to change(ArtPieceTag, :count).by(-5)
    end
  end

  describe '.destroy' do
    it 'removes the tag' do
      art = create :art_piece, :with_tags
      FactoryBot.create :art_piece_tag
      tags = ArtPieceTag.all
      expect do
        expect(art.tags).not_to be_empty
        service.destroy(tags)
        expect(art.tags).to be_empty
      end.to change(ArtPieceTag, :count).by(-3).and(
        change(ArtPiecesTag, :count).by(-2),
      )
    end
  end
end
