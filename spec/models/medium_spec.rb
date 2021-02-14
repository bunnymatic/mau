require 'rails_helper'

describe Medium do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(244).is_at_least(2) }

  describe '#hashtag' do
    let(:name) { 'medium name' }
    subject(:medium) { build(:medium, name: name) }
    its(:hashtag) { is_expected.to eql medium.name.parameterize.underscore }

    context 'for Painting - Oil' do
      let(:name) { 'Painting - Oil' }
      it 'makes returns oilpainting' do
        expect(subject.hashtag).to eql 'oilpainting'
      end
    end

    context 'for Glass/Ceramics' do
      let(:name) { 'Glass/Ceramics' }
      it 'makes returns glass_ceramics' do
        expect(subject.hashtag).to eql 'glass_ceramics'
      end
    end
  end
end
