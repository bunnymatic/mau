require 'spec_helper'

describe ArtistPresenter do

  include PresenterSpecHelpers

  let(:viewer) { FactoryGirl.build(:artist, :active) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art, :with_studio) }
  subject(:presenter) { ArtistPresenter.new(artist) }

  its(:in_the_mission?) { should eql artist.in_the_mission?}
  its(:has_media?) { should be_true }
  its(:has_bio?) { should be_true }
  its(:bio_html) { should eq RDiscount.new(artist.artist_info.bio).to_html.html_safe }
  its(:has_links?) { should be_true }
  its(:links) { should be_present }
  its(:favorites_count) { should be_nil }
  its(:studio_name) { should eql artist.studio.name }
  its(:has_art?) { should be_true }
  it{ should be_valid }

  it 'has a good map div for google maps' do
    map_info = subject.get_map_info
    html = Nokogiri::HTML::DocumentFragment.parse(map_info)
    expect(html.css('.map__info-window-art')).to be_present
  end


  context 'when we wrap a nil artist' do
    let (:artist) { nil }
    it{ should_not be_valid }
  end

  context 'without studio' do
    let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
    it 'has a good map div for google maps' do
      map_info = subject.get_map_info
      html = Nokogiri::HTML::DocumentFragment.parse(map_info)
      expect(html.css('.map__info-window-art')).to be_present
    end
  end

  context 'without media' do
    before do
      ArtPiece.any_instance.stub(:medium => nil)
    end
    its(:has_media?) { should be_false }
  end

  context 'with bio' do
    before do
      ArtistInfo.any_instance.stub(:bio => nil)
    end
    its(:has_bio?) { should be_false }
  end

  context 'with links' do
    before do
      Artist.any_instance.stub(:url => nil,
                               :facebook => nil,
                               :instagram => nil)
    end
    its(:has_links?) { should be_false }
  end

  context 'without art' do
    let(:artist) { FactoryGirl.create(:artist, :active) }
    its(:art_pieces) { should be_empty }
    its(:has_art?) { should be_false }
  end
end
