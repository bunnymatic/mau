require 'spec_helper'

describe ArtPiecePresenter do

  include PresenterSpecHelpers

  let(:artist) { FactoryGirl.create(:artist, :with_art, :active) }
  let(:art_piece) { artist.art_pieces.first }
  subject(:presenter) { ArtPieceJsonPresenter.new(art_piece) }

  it 'prepends image filenames with a /' do
    allow(art_piece).to receive(:get_paths).and_return([{thumb:'blah'}])
    expect(presenter.image_files[:thumb]).to start_with '/'
  end

end
