require 'rails_helper'

describe IndependentStudio do
  describe '#id' do
    subject { described_class.new.id }
    it { should eq 0 }
  end

  describe '#name' do
    subject { described_class.new.name }
    it { should eq 'Independent Studios' }
  end

  describe '#url' do
    subject { described_class.new.url }
    it { should be_nil }
  end

  describe '#profile_image' do
    subject { described_class.new.profile_image }
    it { should match 'independent-studios.jpg' }
  end

  it "to_json is pre-keyed by 'studio'" do
    expect(JSON.parse(described_class.new.to_json)).to have_key 'studio'
  end
end
