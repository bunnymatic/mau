require 'spec_helper'

describe OpenStudiosPresenter do
  let(:open_studios_event) { FactoryGirl.create :open_studios_event }
  let(:indy_artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:studio_artists) { FactoryGirl.create_list :artist, 2, :with_art }
  let(:studio2_artists) { FactoryGirl.create_list :artist, 2, :with_art }
  let(:artists) { [indy_artist] + studio_artists }
  let!(:studio) { FactoryGirl.create :studio, artists: studio_artists }
  let!(:studio2) { FactoryGirl.create :studio, artists: studio2_artists }


  before do
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

  its(:participating_studios) { should have(2).studios }
  its(:participating_indies) { should have(1).artist }
  its(:preview_reception) { should include 'pr header' }
  its(:summary) { should include 'spring 2004' }
  its(:preview_reception_data) { should have_key 'data-cmsid'}
  its(:preview_reception_data) { should have_key 'data-page'}
  its(:preview_reception_data) { should have_key 'data-section'}
  its(:summary_data) { should have_key 'data-cmsid'}
  its(:summary_data) { should have_key 'data-page'}
  its(:summary_data) { should have_key 'data-section'}

  it 'participating studios by name' do
    subject.participating_studios.map(&:name).should be_monotonically_increasing
  end

  it 'participating indys by artist last name' do
    subject.participating_indies.map(&:lastname).map(&:downcase).should be_monotonically_increasing
  end

end
