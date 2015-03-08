require 'spec_helper'

describe ArtistsGallery do

  include PresenterSpecHelpers

  let(:current_page) { 1 }
  let(:per_page) { 2 }
  let(:filter) { nil }
  let(:artists) { FactoryGirl.create_list :artist, 4, :with_art }
  let(:alpha_artists) { artists.sort_by{|a| a.lastname.downcase} }
  let(:showing_artists) { artists.select{|a| a.representative_piece} }
  let(:os_only) { false }

  subject(:presenter) { ArtistsGallery.new(mock_view_context, os_only, current_page, filter, per_page) }

  before do
    fix_leaky_fixtures
    artists
  end

  its(:filters) { should be_empty }
  its(:current_page) { should eql current_page }
  its(:per_page) { should eql per_page }

  it 'shows no artists without a representative piece' do
    expect(presenter.items.select{|a| !a.representative_piece}).to be_empty
    expect(presenter.items.select{|a| a.representative_piece}).to have_at_least(1).artist
  end

  it 'artists include only those with representative pieces sorted by name' do
    expect(subject.artists.map(&:artist)).to eql showing_artists.sort_by(&:sortable_name)
  end

  context 'with a filter set' do
    context 'that matches no one' do
      let(:filter) { ' idareyoutotrytomatchthissucker' }
      it 'returns no artists' do
        expect(subject.artists).to be_empty
      end
    end

    context 'that matches no one with multiple filter words' do
      let(:filter) { ' idareyoutotry tomatchthissucker ' }
      it 'returns no artists' do
        expect(subject.artists).to be_empty
      end
    end

    context 'that matches with an array' do
      let(:filter) { [artists.first.firstname, artists.last.lastname].join "   " }
      it 'returns no artists' do
        found_artists = subject.artists.map(&:artist)
        expect(found_artists).to include artists.first
        expect(found_artists).to include artists.last
      end
    end

    context 'that matches login' do
      let(:filter) { artists.last.login[1..4] }
      it 'filters artists whos login matches the filter (substring match)' do
        expect(subject.artists.map(&:artist)).to include artists.last
      end
    end
    context 'that matches firstname' do
      let(:filter) { artists.last.firstname[1..4] }
      it 'filters artists whos login matches the filter (substring match)' do
        expect(subject.artists.map(&:artist)).to include artists.last
      end
    end
    context 'that matches lastname' do
      let(:filter) { artists.last.lastname[1..4] }
      it 'filters artists whos login matches the filter (substring match)' do
        expect(subject.artists.map(&:artist)).to include artists.last

      end
    end
    context 'that matches nomdeplome' do
      let(:filter) { artists.last.nomdeplume[1..4] }
      it 'filters artists whos login matches the filter (substring match)' do
        expect(subject.artists.map(&:artist)).to include artists.last
      end
    end
  end

end
