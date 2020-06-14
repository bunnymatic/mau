# frozen_string_literal: true

require 'rails_helper'

describe MediaService do
  let(:service) { described_class }

  describe '.media_sorted_by_frequency' do
    let(:art_pieces) { create_list :art_piece, 6 }
    let(:media) { FactoryBot.create_list :medium, 3 }
    before do
      art_pieces.each_with_index do |ap, idx|
        ap.update(medium: idx < 4 ? media[0] : media[1])
      end
    end

    it 'returns tags with their count' do
      freq = service.media_sorted_by_frequency
      expect(freq.first.frequency).to eq 4
      expect(freq.last.frequency).to eq 2
      expect(freq.first).to eq(media[0])
      expect(freq.last).to eq(media[1])
    end
  end

  describe '.most_popular_medium' do
    let(:art_pieces) { create_list :art_piece, 3 }
    let(:media) { FactoryBot.create_list :medium, 2 }
    before do
      art_pieces.each_with_index do |ap, idx|
        ap.update(medium: idx < 2 ? media[1] : media[0])
      end
    end
    it 'returns most popular tag by frequency and medium' do
      expect(described_class.most_popular_medium).to eql(media[1])
    end
  end
end
