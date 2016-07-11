require 'rails_helper'

describe TagCloudPresenter, type: :controller do

  include PresenterSpecHelpers

  let(:mode) { 'a' }
  let(:clz) { ArtPieceTag }
  let(:artist) { FactoryGirl.create :artist, :with_art, number_of_art_pieces: 7 }
  let(:tags) {
    tags = FactoryGirl.create_list(:art_piece_tag, 3)
    artist.art_pieces.reverse.each_with_index do |ap, idx|
      ap.tags = ap.tags + [tags.first]
      ap.tags = ap.tags + [tags.last] if (idx % 3) == 0
      ap.save
    end
    tags
  }
  let(:expected_frequency) { ArtPieceTagService.frequency(true) }
  let(:expected_order) { tags }
  let(:current_tag) { tags[1] }

  subject(:presenter) { TagCloudPresenter.new(clz, current_tag, mode) }

  before do
    fix_leaky_fixtures
    tags
  end

  describe '#current_tag' do
    it { expect(presenter.current_tag).to eql current_tag }
  end

  describe '#mode' do
    it { expect(presenter.mode).to eql mode }
  end

  describe '#frequency' do
    it { expect(presenter.frequency.map{|tf| [tf.tag, tf.frequency]})
         .to eql expected_frequency.map{|tf| [tf.tag, tf.frequency]}  }
  end

  describe '#tags' do
    it "returns tags that have frequency" do
      expect(presenter.tags).to match_array(ArtPieceTag.where(slug: expected_frequency.map{|f| f.tag}).all)
    end
  end


  it 'returns the tag path' do
    expect(presenter.tag_path(current_tag)).to eql art_piece_tag_path(current_tag, m: mode)
  end

  context 'when the mode is art_pieces' do
    let(:mode) { 'p' }
    it 'returns the tag path' do
      expect(presenter.tag_path(current_tag)).to eql art_piece_tag_path(current_tag, m: mode)
    end
  end

end
