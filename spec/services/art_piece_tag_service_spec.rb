# frozen_string_literal: true
require 'rails_helper'

describe ArtPieceTagService do
  let(:service) { described_class }
  let!(:art_pieces) { create_list :art_piece, 6, :with_tags }
  let!(:tags) { FactoryGirl.create_list :art_piece_tag, 5 }

  before do
    Rails.cache.clear
  end

  describe '.tags_sorted_by_frequency' do
    it 'returns tags with their count' do
      freq = service.tags_sorted_by_frequency
      expect(freq.first.frequency).to be >= 1
      expect(freq.last.frequency).to eql 0.0
    end
  end

  describe '.most_popular_tag' do
    before do
      art_piece_tags = [
        create(:art_piece_tag, name: 'hello'),
        create(:art_piece_tag, name: 'hello a'),
        create(:art_piece_tag, name: 'hello b')
      ]
      tags = art_piece_tags.shuffle.map { |t| ArtPieceTagService::TagWithFrequency.new(t.slug, 10) }

      allow(described_class).to receive(:compute_tag_usage).and_return(tags)
    end
    it 'returns most popular tag by frequency and medium' do
      expect(described_class.most_popular_tag).to eql(ArtPieceTag.find('hello'))
    end
  end

  describe '.delete_unused_tags' do
    it 'removes only tags that are unused' do
      expect do
        service.delete_unused_tags
        expect(service.tags_sorted_by_frequency.size).to be >= 7
      end.to change(ArtPieceTag, :count).by(-5)
    end
  end

  describe '.destroy' do
    it 'removes the tag' do
      expect do
        service.delete_unused_tags
        expect(service.tags_sorted_by_frequency.size).to be >= 6
      end.to change(ArtPieceTag, :count).by(-5)
    end
    it 'removes the tag references on any art pieces' do
      tags = service.tags_sorted_by_frequency.select { |tf| tf.frequency > 0 }.first(3).map(&:tag)
      art_piece = tags.first.art_pieces.first
      tag_names = tags.map(&:name)
      expect do
        expect do
          expect(art_piece.tags.map(&:name) & tag_names).not_to be_empty
          service.destroy(tags)
          expect(art_piece.tags.map(&:name) & tag_names).to be_empty
        end.to change(ArtPieceTag, :count).by(-3)
      end.to change(ArtPiecesTag, :count).by(-3)
    end
  end

  describe 'frequency' do
    before do
      art_pieces.each_with_index do |ap, idx|
        ap.tags = tags[0..(5 - idx)]
        ap.save!
      end
    end

    it 'should not throw when getting frequency with no tags' do
      expect { service.frequency }.to_not raise_error
    end

    it 'returns normalized frequency correctly' do
      f = service.frequency
      cts = f.map(&:frequency)
      expect(cts).to eql [1.0, 0.8333333333333334, 0.6666666666666666, 0.5, 0.3333333333333333]
    end
    it 'returns un-normalized frequency correctly' do
      f = service.frequency(false)
      cts = f.map(&:frequency)
      expect(cts).to eql [6.0, 5.0, 4.0, 3.0, 2.0]
    end

    it 'tries the cache on the first hit' do
      expect(SafeCache).to receive(:read).with([:tagfreq, true]).and_return(nil)
      expect(SafeCache).to receive(:write)
      service.frequency(true)
    end
    it 'does not update the cache if it succeeds' do
      expect(SafeCache).to receive(:read).with([:tagfreq, true]).and_return(frequency: 'stuff')
      expect(SafeCache).not_to receive(:write)
      service.frequency(true)
    end
  end

  describe 'flush_cache' do
    it 'flushes the cache' do
      expect(SafeCache).to receive(:delete).with([:tagfreq, true])
      expect(SafeCache).to receive(:delete).with([:tagfreq, false])
      ArtPieceTagService.flush_cache
    end
  end
end
