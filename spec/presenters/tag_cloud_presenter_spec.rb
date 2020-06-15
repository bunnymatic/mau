# frozen_string_literal: true

require 'rails_helper'

describe TagCloudPresenter, type: :controller do
  include PresenterSpecHelpers

  let(:mode) { 'a' }
  let(:artist) { FactoryBot.create :artist, :with_art, number_of_art_pieces: 7 }
  let!(:tags) do
    tags = FactoryBot.create_list(:art_piece_tag, 3)
    artist.art_pieces.reverse.each_with_index do |ap, idx|
      ap.tags = ap.tags + [tags.first]
      ap.tags = ap.tags + [tags.last] if (idx % 3) == 0
      ap.save
    end
    tags
  end
  let(:current) { tags[1] }

  subject(:presenter) { described_class.new(current, mode) }

  describe '#tags' do
    it 'returns tags that have frequency' do
      expect(presenter.tags).to match_array([tags.first, tags.last])
    end
  end

  it 'returns the tag path' do
    expect(presenter.tag_path(current)).to eql art_piece_tag_path(current, m: mode)
  end

  context 'when the mode is art_pieces' do
    let(:mode) { 'p' }
    it 'returns the tag path' do
      expect(presenter.tag_path(current)).to eql art_piece_tag_path(current, m: mode)
    end
  end
end
