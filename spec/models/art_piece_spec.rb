require 'spec_helper'

describe ArtPiece do

  let(:valid_attrs) { FactoryGirl.attributes_for(:art_piece) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:art_piece) { artist.art_pieces.first }

  it{ should validate_presence_of(:title) }
  it{ should ensure_length_of(:title).is_at_least(2).is_at_most(80) }

  describe 'create'  do
    it 'allows quotes' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      expect(ap).to be_valid
    end

    it 'encodes quotes to html numerically' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      expect(ap.safe_title).to eq('what&quot;ever')
    end
  end
  describe 'after save' do
    it 'clears representative image cache and new art cache on save' do
      expect(Rails.cache).to receive(:delete).with("%s%s" % [Artist::CACHE_KEY, artist.id]).at_least(1).times
      expect(Rails.cache).to receive(:delete).with(ArtPieceService::NEW_ART_CACHE_KEY)
      art_piece.title = Faker::Lorem.words(2).join(' ')
      art_piece.save
    end
  end

  describe 'get_path' do
    it 'returns a path to the art piece' do
      expect(art_piece.get_path).to match %r{/system/art_pieces/.*/new-studio.jpg}
    end
  end

  describe 'destroy' do
    it 'tries to delete the files associated with this art piece' do
      File.stub('exist?' => true)
      expect(File).to receive(:delete).exactly(art_piece.get_paths.length).times
      art_piece.destroy
    end
  end

end
