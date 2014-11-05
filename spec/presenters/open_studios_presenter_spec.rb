require 'spec_helper'

describe OpenStudiosPresenter do
  let(:artists) { FactoryGirl.create_list(:artist, 4, :with_art, :with_studio) }
  let!(:studio) { FactoryGirl.create :studio, artists: artists }

  its(:participating_studios) { should have_at_least(1).studio }
  its(:participating_indies) { should have_at_least(1).artist }
  its(:preview_reception) { should be_a_kind_of String }
  its(:summary) { should be_a_kind_of String}
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
