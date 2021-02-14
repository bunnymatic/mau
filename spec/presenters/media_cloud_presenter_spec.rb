require 'rails_helper'

describe MediaCloudPresenter, type: :controller do
  include PresenterSpecHelpers

  let(:artist) { FactoryBot.create :artist, :with_art, number_of_art_pieces: 7 }
  let!(:media) do
    mediums = FactoryBot.create_list(:medium, 3)
    artist.art_pieces.reverse_each.with_index do |ap, idx|
      ap.update(medium: mediums[idx % 2])
    end
    mediums
  end
  let(:current) { media[1] }

  subject(:presenter) { described_class.new(current) }

  describe '#media' do
    it 'returns media that have frequency' do
      expect(presenter.to_a).to match_array([media[1], media[0]])
    end
  end

  it 'returns the medium path' do
    expect(presenter.medium_path(current)).to eql medium_path(current)
  end
end
