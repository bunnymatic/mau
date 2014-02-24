require 'spec_helper'

describe ThumbnailBrowserPresenter do

  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create(:artist, :with_art, :active) }
  let(:art_piece) { artist.art_pieces[1] }
  subject(:presenter) { ThumbnailBrowserPresenter.new(mock_view_context, artist, art_piece) }

  its(:pieces) { should have(artist.art_pieces.count).pieces }
  its(:thumbs) { should have(artist.art_pieces.count).pieces }
  its(:has_thumbs?) { should be_true }
  its(:row_class) { should eql 'rows1' }
  its(:thumbs_json) { should be_a_kind_of String }
  its(:next_img) { should eql artist.art_pieces[2].id }
  its(:prev_img) { should eql artist.art_pieces[0].id }
  its(:current_index) { should eql 1 }

end
