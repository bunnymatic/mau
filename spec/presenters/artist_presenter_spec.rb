require 'rails_helper'

describe ArtistPresenter do

  include PresenterSpecHelpers

  let(:viewer) { FactoryGirl.build(:artist, :active) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art, :with_studio) }
  subject(:presenter) { ArtistPresenter.new(artist) }

  context "when the subject is an artist" do
    its(:artist?) { is_expected.to eq true }
    its(:in_the_mission?) { is_expected.to eql artist.in_the_mission? }
    its(:has_media?) { is_expected.to eql true }
    its(:has_bio?) { is_expected.to eql true }
    its(:bio_html) { is_expected.to eql RDiscount.new(artist.artist_info.bio).to_html.html_safe }
    its(:has_links?) { is_expected.to eql true }
    its(:links) { is_expected.to be_present }
    its(:favorites_count) { is_expected.to be_nil }
    its(:studio_name) { is_expected.to eql artist.studio.name }
    its(:has_art?) { is_expected.to eql true }
    it{ should be_valid }

    describe '#get_share_link' do
      it "returns the artists link" do
        expect(subject.get_share_link).to match %r|/artists/#{artist.login}$|
      end
      it "returns the html safe artists link given html_safe = true" do
        expect(subject.get_share_link(true).downcase).to match %r|%2fartists%2f#{artist.login}$|
      end
      it "returns the artists link with params given params" do
        expect(subject.get_share_link(false, this: "that")).to match %r|artists/#{artist.login}\?this=that$|
      end
    end

    it 'has a good map div for google maps' do
      map_info = subject.get_map_info
      html = Capybara::Node::Simple.new(map_info)
      expect(html).to have_selector('.map__info-window-art')
    end

    context 'when we wrap a nil artist' do
      let (:artist) { nil }
      it{ should_not be_valid }
    end

    context 'without studio' do
      let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
      it 'has a good map div for google maps' do
        map_info = subject.get_map_info
        html = Capybara::Node::Simple.new(map_info)
        expect(html).to have_css('.map__info-window-art')
      end
    end

    context 'without media' do
      before do
        allow_any_instance_of(ArtPiece).to receive(:medium).and_return(nil)
      end

      its(:has_media?) { is_expected.to eql false }
      its(:primary_medium) { is_expected.to eql '' }
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
        allow(artist).to receive(:website).and_return(nil)
        allow(artist).to receive(:facebook).and_return(nil)
        allow(artist).to receive(:instagram).and_return(nil)
      end

      describe '#has_links?' do
        its(:has_links?) { is_expected.to eq false }
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

  context "when the subject is a fan" do
    let(:artist) { FactoryGirl.create(:mau_fan, :active) }
    describe 'artist?' do
      its(:artist?) { is_expected.to eq false }
    end
  end
end
