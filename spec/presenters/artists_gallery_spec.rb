require 'spec_helper'

describe ArtistsGallery do

  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) { FactoryGirl.create_list :artist, 4, :with_art }
  let(:alpha_artists) { artists.sort_by{|a| a.lastname.downcase} }
  let(:showing_artists) { artists.select{|a| a.representative_piece} }
  let(:os_only) { false }

  subject(:presenter) { ArtistsGallery.new(mock_view_context, os_only, current_page, per_page) }

  before do
    fix_leaky_fixtures
    artists
  end

  its(:current_page) { should eql current_page }
  its(:per_page) { should eql per_page }
  its(:last_page) { should eql (showing_artists.length.to_f / per_page.to_f).to_i - 1 }
  its(:first_page) { should eql 0 }

  it 'shows no artists without a representative piece' do
    expect(presenter.items.select{|a| !a.representative_piece}).to be_empty
    expect(presenter.items.select{|a| a.representative_piece}).to have_at_least(1).artist
  end

  it 'artists include only those with representative pieces sorted by name' do
    expect(subject.artists.map(&:artist)).to eql showing_artists.sort_by(&:sortable_name)
  end

  describe '.alpha_links' do
    let(:alpha_links) { subject.alpha_links }
    let(:alpha_links_text) { alpha_links.map(&:first) }
    let(:alpha_links_pages) { alpha_links.map{|l| l[1] }}
    let(:alpha_links_current_page) { alpha_links.map(&:last) }
    its(:alpha_links) { should be_a_kind_of Array }
    it 'includes the page attrs' do
      expect(alpha_links_pages.map{|page| page[:p]}).to eql [0,1]
    end
    it 'includes the right text' do
      expect(alpha_links_text.first[0..1]).to eql alpha_artists.first.lastname[0..1].capitalize
    end
  end

end
