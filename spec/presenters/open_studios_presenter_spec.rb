# frozen_string_literal: true
require 'rails_helper'

describe OpenStudiosPresenter do
  let(:open_studios_event) { FactoryGirl.create :open_studios_event }
  let(:indy_artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:studio_artists) { FactoryGirl.create_list :artist, 2, :with_art }
  let(:studio2_artists) { FactoryGirl.create_list :artist, 2, :with_art }
  let(:artists) { [indy_artist] + studio_artists }
  let!(:studio) { FactoryGirl.create :studio, artists: studio_artists }
  let!(:studio2) { FactoryGirl.create :studio, artists: studio2_artists }
  subject(:presenter) { described_class.new }

  before do
    [studio, studio2].each do |s|
      s.update_attribute :lat, 37.75
      s.update_attribute :lng, -122.41
    end
    indy_artist.artist_info.update_attribute :lat, 37.75
    indy_artist.artist_info.update_attribute :lng, -122.41

    FactoryGirl.create(:cms_document,
                       page: :main_openstudios,
                       section: :summary,
                       article: "# spring 2004\n\n## spring 2004 header2 \n\nwhy spring 2004?  that's _dumb_.")
    FactoryGirl.create(:cms_document,
                       page: :main_openstudios,
                       section: :preview_reception,
                       article: "# pr header\n\n## pr header2\n\ncome out to the *preview* receiption")
    artists.first(2).each { |a| a.update_os_participation open_studios_event.key, true }
    studio2_artists.last(3).each { |a| a.update_os_participation open_studios_event.key, true }
  end

  describe '#participating_studios' do
    it 'has 2 studios' do
      expect(presenter.participating_studios.size).to eq(2)
    end
  end

  describe '#participating_indies' do
    it 'has 1 artist' do
      expect(presenter.participating_indies.size).to eq(1)
    end
  end

  describe '#preview_reception' do
    subject { super().preview_reception }
    it { should include 'pr header' }
  end

  describe '#summary' do
    subject { super().summary }
    it { should include 'spring 2004' }
  end

  describe '#preview_reception_data' do
    subject { super().preview_reception_data }
    it { should have_key 'data-cmsid' }
  end

  describe '#preview_reception_data' do
    subject { super().preview_reception_data }
    it { should have_key 'data-page' }
  end

  describe '#preview_reception_data' do
    subject { super().preview_reception_data }
    it { should have_key 'data-section' }
  end

  describe '#summary_data' do
    subject { super().summary_data }
    it { should have_key 'data-cmsid' }
  end

  describe '#summary_data' do
    subject { super().summary_data }
    it { should have_key 'data-page' }
  end

  describe '#summary_data' do
    subject { super().summary_data }
    it { should have_key 'data-section' }
  end

  it 'participating studios by name' do
    expect(subject.participating_studios.map(&:name)).to be_monotonically_increasing
  end

  it 'participating indys by artist last name' do
    expect(subject.participating_indies.map(&:lastname).map(&:downcase)).to be_monotonically_increasing
  end
end
