require 'spec_helper'

describe MediaPresenter do

  fixtures :art_pieces, :users, :artist_infos, :media

  include PresenterSpecHelpers

  let(:page) { 1 }
  let(:mode) { nil }
  let(:per_page) { 2 }
  let(:select_medium) { media(:medium2) }

  subject(:presenter) { MediaPresenter.new(mock_view_context, select_medium, page, mode, per_page) }

  it 'fixture validation' do
    expect(select_medium.art_pieces.count).to be > 2
  end

  its(:by_artists?) { should be_false }
  its(:by_pieces?) { should be_true }
  its(:all_art_pieces) { should have(select_medium.art_pieces.count).art_pieces }
  its(:art_pieces) { should have(2).items }
  its(:paginator) { should be_a_kind_of MediumPagination }

  its('paginator.per_page') { should eql per_page }
  its('paginator.current_page') { should eql page }

end
