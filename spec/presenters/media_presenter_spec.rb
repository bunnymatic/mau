require 'spec_helper'

describe MediaPresenter do

  include PresenterSpecHelpers

  let(:media) { FactoryGirl.create_list(:medium, 4) }
  let(:artists) { FactoryGirl.create_list(:artist, 5, :with_art) }
  let!(:art_pieces) do
    pieces = artists.map(&:art_pieces).flatten
    pieces.each { |ap| ap.update_attribute :medium_id, select_medium.id }
  end

  let(:page) { 1 }
  let(:mode) { nil }
  let(:per_page) { 2 }
  let(:select_medium) { media.last }

  subject(:presenter) { MediaPresenter.new(mock_view_context, select_medium, page, mode, per_page) }

  its(:by_artists?) { should be_false }
  its(:by_pieces?) { should be_true }
  its(:all_art_pieces) { should have(select_medium.art_pieces.count).art_pieces }
  its(:art_pieces) { should have(2).items }
  its(:paginator) { should be_a_kind_of MediumPagination }

  its('paginator.per_page') { should eql per_page }
  its('paginator.current_page') { should eql page }

end
