require 'rails_helper'

describe ArtistPresenter do

  include PresenterSpecHelpers

  let(:viewer) { FactoryGirl.build(:artist, :active) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art, :with_studio) }
  subject(:presenter) { ArtistPresenter.new(artist) }

  describe '#in_the_mission?' do
    subject { super().in_the_mission? }
    it { should eql artist.in_the_mission?}
  end

  describe '#has_media?' do
    subject { super().has_media? }
    it { should eq(true) }
  end

  describe '#has_bio?' do
    subject { super().has_bio? }
    it { should eq(true) }
  end

  describe '#bio_html' do
    subject { super().bio_html }
    it { should eq RDiscount.new(artist.artist_info.bio).to_html.html_safe }
  end

  describe '#has_links?' do
    subject { super().has_links? }
    it { should eq(true) }
  end

  describe '#links' do
    subject { super().links }
    it { should be_present }
  end

  describe '#favorites_count' do
    subject { super().favorites_count }
    it { should be_nil }
  end

  describe '#studio_name' do
    subject { super().studio_name }
    it { should eql artist.studio.name }
  end

  describe '#has_art?' do
    subject { super().has_art? }
    it { should eq(true) }
  end
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
      allow_any_instance_of(ArtPiece).to receive(:medium).and_return(nil)
    end

    describe '#has_media?' do
      subject { super().has_media? }
      it { should eq false }
    end
  end

  context 'without bio' do
    before do
      allow(artist).to receive_message_chain(:artist_info, :bio).and_return(nil)
    end

    describe '#has_bio?' do
      subject { super().has_bio? }
      it { should eq false }
    end
  end

  context 'without links' do
    before do
      allow(artist).to receive(:url).and_return(nil)
      allow(artist).to receive(:facebook).and_return(nil)
      allow(artist).to receive(:instagram).and_return(nil)
    end

    describe '#has_links?' do
      subject { super().has_links? }
      it { should eq false }
    end
  end

  context 'without art' do
    let(:artist) { FactoryGirl.create(:artist, :active) }

    describe '#art_pieces' do
      subject { super().art_pieces }
      it { should be_empty }
    end

    describe '#has_art?' do
      subject { super().has_art? }
      it { should eq false }
    end
  end
end
