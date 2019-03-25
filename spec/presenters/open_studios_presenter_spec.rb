# frozen_string_literal: true

require 'rails_helper'

describe OpenStudiosPresenter do
  subject(:presenter) { described_class.new }

  before do
    allow(CmsDocument).to receive(:packaged)
      .with('main_openstudios', 'summary')
      .and_return(
        page: 'main_openstudios',
        section: 'summary',
        content: "# spring 2004\n\n## spring 2004 header2 \n\nwhy _spring_.",
        cmsid: 1,
      )
    allow(CmsDocument).to receive(:packaged)
      .with('main_openstudios', 'preview_reception')
      .and_return(
        page: 'main_openstudios',
        section: 'preview_reception',
        content: '# pr header\n\n## pr header2\n\ncome out to the *preview* receiption',
        cmsid: 1,
      )
    allow(Artist).to receive_message_chain(
      :active, :open_studios_participants, :in_the_mission
    ).and_return([
                   instance_double(Artist, studio: instance_double(Studio, name: 'studio')),
                   instance_double(Artist, studio: instance_double(Studio, name: 'studio2')),
                   instance_double(Artist, studio: nil, address: 'mission', lastname: 'Rogers'),
                 ])
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
    it { is_expected.to include 'pr header' }
  end

  describe '#summary' do
    subject { super().summary }
    it { is_expected.to include 'spring 2004' }
  end

  describe '#preview_reception_data' do
    subject { super().preview_reception_data }
    it { is_expected.to have_key 'data-cmsid' }
  end

  describe '#preview_reception_data' do
    subject { super().preview_reception_data }
    it { is_expected.to have_key 'data-page' }
  end

  describe '#preview_reception_data' do
    subject { super().preview_reception_data }
    it { is_expected.to have_key 'data-section' }
  end

  describe '#summary_data' do
    subject { super().summary_data }
    it { is_expected.to have_key 'data-cmsid' }
  end

  describe '#summary_data' do
    subject { super().summary_data }
    it { is_expected.to have_key 'data-page' }
  end

  describe '#summary_data' do
    subject { super().summary_data }
    it { is_expected.to have_key 'data-section' }
  end

  it 'participating studios by name' do
    expect(subject.participating_studios.map(&:name)).to be_monotonically_increasing
  end

  it 'participating indys by artist last name' do
    expect(subject.participating_indies.map(&:lastname).map(&:downcase)).to be_monotonically_increasing
  end
end
