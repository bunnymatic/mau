require "spec_helper"

describe SearchService do

  # fixtures :users, :roles, :roles_users
  # fixtures :artist_infos
  # fixtures :art_pieces
  # fixtures :media
  # fixtures :art_piece_tags
  # fixtures :art_pieces_tags
  # fixtures :studios

  before do
    Rails.cache.clear
  end

  let(:open_studios_event) { FactoryGirl.create(:open_studios_event) }
  let(:nomdeplume_artist) { Artist.active.where(nomdeplume:'Interesting').first }
  let(:artists) { Artist.all}
  let(:artist) { artists.first }
  let(:art_piece) { artist.art_pieces.first }
  let(:medium) { art_piece.medium }
  let(:tag) { art_piece.tags.last }
  let(:studios) { artists.map(&:studio) }
  let(:search_mediums) { [] }
  let(:search_studios) { [] }
  let(:keywords) { '' }
  let(:os_flag) { nil }
  let(:query) {
    SearchQuery.new(keywords: keywords,
                       studios: search_studios.map{|s| s.try(:id).to_i },
                       mediums: search_mediums.map(&:id),
                       os_artist: os_flag)
  }
  
  before(:all) do
    FactoryGirl.create_list(:artist, 3, :with_studio, :with_tagged_art, firstname: 'Firstname')
    FactoryGirl.create(:artist, nomdeplume: "Interesting", firstname: 'Firstname' )
    FactoryGirl.create(:artist, :active, :with_art, nomdeplume: "Interesting", firstname: 'Firstname')
  end

  subject(:search) { SearchService.new(query) }
  let(:results) { subject.search }


  context 'with no params' do
    its(:search) { should have(0).items }
  end

  context 'with non-matching keywords' do
    let(:keywords) { ['this long thing', 'wont', 'match anything'].join(",") }
    its(:search) { should have(0).items }
  end

  context 'with a simple keyword' do
    let(:keywords) { 'firstname' }
    its(:search) { should have(12).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
  end

  context 'finding by medium' do
    let(:search_mediums) { artists.map{|a| a.art_pieces.map(&:medium) }.flatten.compact.slice(0,2) }
    its(:search) { should have(2).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it 'results should use one of the included media' do
      found = results.map{|r| r.medium.id }
      expect( search_mediums.map(&:id) & found).to have_at_least(1).item
    end
  end

  context 'finding by medium and studio' do
    let(:search_mediums) { artists.map{|a| a.art_pieces.map(&:medium) }.flatten.compact.slice(0,2) }
    let(:search_studios) { artists.map(&:studio).slice(0,2) }
    let(:keywords) { 'firstname' }
    its(:search) { should have(2).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it 'results should use one of the included media' do
      found = results.map{|r| r.medium.id }
      expect( search_mediums.map(&:id) & found).to have_at_least(1).item
    end
    it 'results should come from one of the included studios' do
      found = results.map{|r| r.artist.studio.id }
      expect( search_studios.map(&:id) & found).to have_at_least(1).item
    end
  end

  context 'finding by partial nomdeplume' do
    let(:keywords) { "Interesting" }
    its(:search) { should have(3).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it { expect(results.map(&:artist)).to include nomdeplume_artist }
  end

  context 'last name' do
    let(:keywords) { artist.lastname }
    its(:search) { should have_at_least(1).item }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it { expect(results.map(&:artist).uniq).to eql [artist] }
  end

  context "firstname with extra spaces in the query" do
    let(:keywords) { " " + artist.lastname + "  " }
    its(:search) { should have_at_least(1).item }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it { expect(results.map(&:artist).uniq).to eql [artist] }
  end

  context "full name with capitalization" do
    let(:keywords) { artist.full_name.titleize }
    its(:search) { should have_at_least(1).item }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it { expect(results.map(&:artist).uniq).to eql [artist] }
  end

  context 'finding an art piece by title' do
    let(:keywords) { art_piece.title.last }
    its(:search) { should have_at_least(1).item }
    it { expect(results).to include art_piece }
  end

  context "finding by art piece partial title" do
    let(:keywords) { art_piece.title.split.first }
    its(:search) { should have_at_least(1).item }
    it { expect(results).to include art_piece }
  end

  context "finding by tag" do
    let(:keywords) { tag.name }
    its(:search) { should have_at_least(1).item }
    it { expect(results.map{|r| r.tags.map(&:name)}.flatten).to include tag.name }
  end

  context 'finding by keyword that matches a medium' do
    let(:keywords) { medium.name }
    its(:search) { should have(1).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it 'results should use one of the included media' do
      results.each do |r|
        expect(r.medium).to eql medium
      end
    end
  end

  context 'finding indy studio work' do
    let(:search_studios) { [Studio.indy] }
    its(:search) { should have_at_least(1).item }
    
    it { expect(results.map{|r| r.artist.studio_id.to_i}.uniq).to eql [0] }
  end

  context 'finding only os artists' do
    let(:keywords) { 'firstname' }
    let(:os_flag) { "1" }
    before do
      artist.update_os_participation open_studios_event.key, true
    end
    its(:search) { should have_at_least(1).item }
    it { expect(results.map{|r| r.artist.doing_open_studios?}.uniq).to eql [true] }
  end

  context 'finding only non os artists' do
    let(:keywords) {'firstname' }
    let(:os_flag) { "2" }
    its(:search) { should have_at_least(1).item }
    it { expect(results.map{|r| r.artist.doing_open_studios?}.uniq).to eql [false] }
  end

  context 'finding by studio' do
    let(:keywords) { 'firstname' }
    let(:search_studios) { [studios[1]] }

    it { expect(results).to have(9).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it 'results should come from one of the included studios' do
      found = results.map{|r| r.artist.studio.try(:id) }
      expect( search_studios.map(&:id) & found).to have_at_least(1).item
    end
  end

end
