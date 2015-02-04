require 'spec_helper'

describe StudioPresenter do

  include PresenterSpecHelpers

  let(:studio) { FactoryGirl.create(:studio, :cross_street => 'hollywood') }
  let!(:artist1) { FactoryGirl.create(:artist, :active, :with_art, :studio => studio) }
  let!(:artist2) { FactoryGirl.create(:artist, :active, :studio => studio) }
  let!(:artist3) { FactoryGirl.create(:artist, :pending, :studio => studio) }
  subject(:presenter) { StudioPresenter.new(mock_view_context, studio) }

  its(:has_artists_with_art?) { should be_true }
  its(:artists_with_art) { should have(1).artist }
  its(:has_artists_without_art?) { should be_true }
  its(:artists_without_art) { should have(1).artist }
  its(:name) { should eql studio.name }
  its(:street_with_cross) { should eql "#{studio.street} (@ hollywood)" }
  its(:image) { should start_with "/studiodata/#{studio.id}" }
  its(:indy?) { should be_false }

  it '.artists returns the active artists' do
    presenter.artists.should eq studio.artists.active
  end

  context 'without image file' do
    let(:studio) { FactoryGirl.create(:studio, :profile_image => nil) }
    its(:image) { should eql '/images/default-studio.png' }
  end
end
