require "spec_helper"

describe MauSearch do

  # fixtures :users, :roles, :roles_users
  # fixtures :artist_infos
  # fixtures :art_pieces
  # fixtures :media
  # fixtures :art_piece_tags
  # fixtures :art_pieces_tags
  # fixtures :studios

  before do
    Rails.cache.stub(:read => nil)
  end
  
  let(:artists) { FactoryGirl.create_list :artist, 3, :with_studio, :with_tagged_art }
  let(:studios) { artists.map(&:studio) }
  let(:search_mediums) { [] }
  let(:search_studios) { [] }
  let(:keywords) { '' }
  let(:os_flag) { nil }
  let(:query) {
    MauSearchQuery.new(keywords: keywords,
                       studios: search_studios.map(&:id),
                       mediums: search_mediums.map(&:id),
                       os_artist: os_flag)
  }
  
  subject(:search) { MauSearch.new(query) }
  let(:results) { subject.search }


  context 'with no params' do
    its(:search) { should have(0).items }
  end

  context 'with non-matching keywords' do
    let(:keywords) { ['this long thing', 'wont', 'match anything'].join(",") }
    its(:search) { should have(0).items }
  end

  context 'with a simple keyword' do
    let(:keywords) { 'a' }
    its(:search) { should have(9).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
  end

  context 'finding by medium' do
    let(:search_mediums) { [ media(:medium1), media(:medium2) ] }
    its(:search) { should have(6).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it 'results should use one of the included media' do
      found = results.map{|r| r.medium.id }
      expect( search_mediums.map(&:id) & found).to have_at_least(1).item
    end
  end

  context 'finding by medium and studio' do
    let(:search_mediums) { [ media(:medium1), media(:medium2) ] }
    let(:search_studios) { [ studios(:as), studios(:s1890) ] }
    let(:keywords) { 'a' }
    its(:search) { should have(1).items }
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
    its(:search) { should have(1).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it { expect(results.first.artist).to eql users(:nomdeplume) }
  end

  let(:annafizyta) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:artist1) { FactoryGirl.create(:artist, :active, :with_art) }
  [:annafizyta, :artist1].each do |user|
    %w[ firstname lastname fullname].each do |term|
      context "for #{user} by #{term}" do
        let(:artist) { users(user) }
        let(:keywords) { artist.send(term) }
        its(:search) { should have_at_least(1).item }
        it { expect(results.first).to be_a_kind_of ArtPiece }
        it { expect(results.map(&:artist).uniq).to eql [artist] }
      end

      context "for #{user} by #{term} with extra spaces in the query" do
        let(:artist) { users(user) }
        let(:keywords) { " " + artist.send(term) + "  " }
        its(:search) { should have_at_least(1).item }
        it { expect(results.first).to be_a_kind_of ArtPiece }
        it { expect(results.map(&:artist).uniq).to eql [artist] }
      end

      context "for #{user} by #{term} with capitalization" do
        let(:artist) { users(user) }
        let(:keywords) { artist.send(term).titleize }
        its(:search) { should have_at_least(1).item }
        it { expect(results.first).to be_a_kind_of ArtPiece }
        it { expect(results.map(&:artist).uniq).to eql [artist] }
      end

    end
  end

  context 'finding an art piece by title' do
    let(:art_piece) { art_pieces(:hotter) }
    let(:keywords) { art_piece.title.last }
    its(:search) { should have_at_least(1).item }
    it { expect(results).to include art_piece }
  end

  context "finding by art piece partial title" do
    let(:art_piece) { art_pieces(:hotter) }
    let(:keywords) { art_piece.title.split.first }
    its(:search) { should have_at_least(1).item }
    it { expect(results).to include art_piece }
  end

  context "finding by tag" do
    let(:tag) { art_piece_tags(:one) }
    let(:keywords) { tag.name }
    its(:search) { should have_at_least(1).item }
    it { expect(results.map{|r| r.tags.map(&:name)}.flatten).to include tag.name }
  end

  context 'finding by keyword that matches a medium' do
    let(:keywords) { media(:medium1).name }
    its(:search) { should have(2).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it 'results should use one of the included media' do
      results.each do |r|
        expect(r.medium).to eql media(:medium1)
      end
    end
  end

  context 'finding indy studio work' do
    let(:search_studios) { [Studio.indy] }
    its(:search) { should have_at_least(1).item }
    it { expect(results.map{|r| r.artist.studio_id}.uniq).to eql [0] }
  end

  context 'finding only os artists' do
    let(:keywords) { 'a' }
    let(:os_flag) { "1" }
    its(:search) { should have_at_least(1).item }
    it { expect(results.map{|r| r.artist.doing_open_studios?}.uniq).to eql [true] }
  end

  context 'finding only non os artists' do
    let(:keywords) { 'a' }
    let(:os_flag) { "2" }
    its(:search) { should have_at_least(1).item }
    it { expect(results.map{|r| r.artist.doing_open_studios?}.uniq).to eql [false] }
  end

  context 'finding by studio' do
    let(:keywords) { 'a' }
    let(:search_studios) { studios }

    it { expect(results).to have(2).items }
    it { expect(results.first).to be_a_kind_of ArtPiece }
    it 'results should come from one of the included studios' do
      found = results.map{|r| r.artist.studio.id }
      expect( search_studios.map(&:id) & found).to have_at_least(1).item
    end
  end

end
