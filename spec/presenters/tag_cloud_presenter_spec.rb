require 'spec_helper'

describe TagCloudPresenter do

  include PresenterSpecHelpers

  fixtures :art_piece_tags, :art_pieces_tags, :art_pieces

  let(:expected_order) {
    [:one, :two, :three, :with_spaces].map{|k| art_piece_tags(k).id}
  }
  let(:current_tag) { expected_order[1] }
  let(:mode) { 'a' }
  let(:clz) { ArtPieceTag }
  let(:expected_frequency) { ArtPieceTag.frequency(true) }
  subject(:cloud) { TagCloudPresenter.new(mock_view_context, clz, current_tag, mode) }

  its(:current_tag) { should eql current_tag }
  its(:mode) { should eql mode }
  its(:frequency) { should eql expected_frequency }
  its('tags.all') { should eql ArtPieceTag.where(:id => expected_frequency.map{|f| f['tag']}).all }

  it 'returns the tag path' do
    expect(subject.tag_path(current_tag)).to eql art_piece_tag_path(current_tag, :m => mode)
  end

  it 'computes the style for the most popular tag' do
    expect(subject.compute_style(expected_frequency.first)).
      to eql "font-size:24px; margin: 4px;"
  end

  it 'computes the style for the least popular tag' do
    expect(subject.compute_style(expected_frequency.last)).
      to eql "font-size:16px; margin: 4px;"
  end

  context 'when the mode is art_pieces' do
    let(:mode) { 'p' }
    it 'returns the tag path' do
      expect(subject.tag_path(current_tag)).to eql art_piece_tag_path(current_tag, :m => mode)
    end
  end

end
