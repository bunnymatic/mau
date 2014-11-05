require 'spec_helper'

describe TagCloudPresenter, :type => :controller do

  include PresenterSpecHelpers

  let(:mode) { 'a' }
  let(:clz) { ArtPieceTag }
  let(:artist) { FactoryGirl.create :artist, :with_art, number_of_art_pieces: 7 }
  let!(:tags) { 
    tags = FactoryGirl.create_list(:art_piece_tag, 3)
    artist.art_pieces.reverse.each_with_index do |ap, idx|
      ap.tags = ap.tags + [tags.first]
      ap.tags = ap.tags + [tags.last] if (idx % 3) == 0
      ap.save
    end
    tags
  }
  let(:expected_frequency) do
    ArtPieceTag.frequency(true)
  end

  let(:expected_order) { tags }
  let(:current_tag) { tags[1] }

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
      to eql "font-size:17px; margin: 4px;"
  end

  context 'when the mode is art_pieces' do
    let(:mode) { 'p' }
    it 'returns the tag path' do
      expect(subject.tag_path(current_tag)).to eql art_piece_tag_path(current_tag, :m => mode)
    end
  end

end
