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
      ap.should be_valid
    end

    it 'encodes quotes to html numerically' do
      p = valid_attrs.merge({:title => 'what"ever'})
      ap = ArtPiece.new(p)
      ap.safe_title.should == 'what&quot;ever'
    end
  end
  describe 'after save' do
    it 'clears representative image cache and new art cache on save' do
      Rails.cache.should_receive(:delete).with("%s%s" % [Artist::CACHE_KEY, artist.id]).at_least(1).times
      Rails.cache.should_receive(:delete).with(ArtPieceService::NEW_ART_CACHE_KEY)
      art_piece.title = Faker::Lorem.words(2).join(' ')
      art_piece.save
    end
  end

  describe 'get_path' do
    it 'returns a path to the art piece' do
      art_piece.get_path.should match %r{/system/art_pieces/.*/new-studio.jpg}
    end
  end

  describe 'destroy' do
    it 'tries to delete the files associated with this art piece' do
      File.stub('exist?' => true)
      File.should_receive(:delete).exactly(art_piece.get_paths.length).times
      art_piece.destroy
    end
  end

end
