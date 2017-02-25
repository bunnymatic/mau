# frozen_string_literal: true
require 'rails_helper'

describe IndependentStudio do
  describe '#id' do
    subject { super().id }
    it { should eq 0 }
  end

  describe '#name' do
    subject { super().name }
    it { should eq "Independent Studios" }
  end

  describe '#url' do
    subject { super().url }
    it { should be_nil }
  end

  describe '#get_profile_image' do
    subject { super().get_profile_image }
    it { should match 'independent-studios.jpg' }
  end

  it "to_json is pre-keyed by 'studio'" do
    expect(JSON.parse(IndependentStudio.new.to_json)).to have_key "studio"
  end
end
