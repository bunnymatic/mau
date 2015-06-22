require 'spec_helper'

describe ArtistsGallery do

  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:artists) {
    [
      create(:artist, :with_art, lastname: 'Abby'),
      create(:artist, :with_art, lastname: 'Asinine'),
      create(:artist, :with_art, lastname: 'Atkins'),
      create(:artist, :with_art, lastname: 'bab'),
      create(:artist, :with_art, lastname: 'cab'),
      create(:artist, :with_art, lastname: ''),
      create(:artist, lastname: 'Arnold'),
      create(:artist, lastname: 'Bored')
   ]
  }
  let(:showing_artists) { artists.first(per_page) }
  let(:os_only) { false }

  subject(:presenter) { ArtistsGallery.new(os_only, 'A', current_page, per_page) }

  before do
    fix_leaky_fixtures
    artists
  end

  its(:current_page) { should eql current_page }
  its(:per_page) { should eql per_page }
  its(:empty_message) { should include "couldn't find any artists" }

  it 'shows no artists without a representative piece' do
    with_art, without_art = presenter.items.partition{|a| a.representative_piece}
    expect(without_art).to be_empty
    expect(with_art).to have(1).artist
    expect(with_art.first.lastname).to eql 'Atkins'
  end

  it 'artists include only those with representative pieces sorted by name' do
    expect(subject.artists.map(&:artist)).to eql artists.first(3)
  end

  context 'with open studios set true' do
    let(:os_only) { true }
    its(:empty_message) { should include "no one with that last name has signed up" }
  end

end
