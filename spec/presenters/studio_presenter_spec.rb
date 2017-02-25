# frozen_string_literal: true
require 'rails_helper'

describe StudioPresenter do
  let(:studio) { FactoryGirl.create(:studio, cross_street: 'hollywood', phone: '4156171234') }
  let!(:artist1) { FactoryGirl.create(:artist, :active, :with_art, studio: studio) }
  let!(:artist2) { FactoryGirl.create(:artist, :active, studio: studio) }
  let!(:artist3) { FactoryGirl.create(:artist, :pending, studio: studio) }
  subject(:presenter) { StudioPresenter.new(studio) }

  describe '#has_artists_with_art?' do
    subject { super().has_artists_with_art? }
    it { should eq(true) }
  end

  describe '#artists_with_art' do
    subject { super().artists_with_art }

    it 'has 1 artist' do
      expect(subject.size).to eq(1)
    end
  end

  describe '#has_artists_without_art?' do
    subject { super().has_artists_without_art? }
    it { should eq(true) }
  end

  describe '#artists_without_art' do
    subject { super().artists_without_art }

    it 'has 1 artist' do
      expect(subject.size).to eq(1)
    end
  end

  describe '#name' do
    subject { super().name }
    it { should eql studio.name }
  end

  describe '#street_with_cross' do
    subject { super().street_with_cross }
    it { should eql "#{studio.street} (@ hollywood)" }
  end

  describe '#indy?' do
    subject { super().indy? }
    it { should be_falsey }
  end

  it '.artists returns the active artists' do
    expect(presenter.artists).to eq studio.artists.active
  end

  describe 'formatted_phone' do
    it 'returns nicely formatted phone #' do
      expect(presenter.formatted_phone).to eql '(415) 617-1234'
    end
  end
end
