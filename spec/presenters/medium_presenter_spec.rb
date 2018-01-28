# frozen_string_literal: true

require 'rails_helper'

describe MediumPresenter do
  let(:medium) { build :medium }
  subject(:presenter) { described_class.new(medium) }

  describe '#hashtag' do
    it 'parameterizes the name' do
      expect(subject.hashtag).to eql medium.name.parameterize.underscore
    end

    # "Drawing!",
    # "Mixed-Media",
    # "Photography",
    # "Glass/Ceramics",
    # "Printmaking",
    # "Painting - Oil",
    # "Painting - Acrylic",
    # "Painting - Watercolor",
    # "Sculpture",
    # "Jewelry",
    # "Fiber/Textile",
    # "Furniture!",
    # "pencils",
    # "Painting - Encaustic",
    # "Wooden"

    context 'for Painting - Oil' do
      let(:medium) { build :medium, name: 'Painting - Oil' }
      it 'makes returns oilpainting' do
        expect(subject.hashtag).to eql 'oilpainting'
      end
    end

    context 'for Glass/Ceramics' do
      let(:medium) { build :medium, name: 'Glass/Ceramics' }
      it 'makes returns oilpainting' do
        expect(subject.hashtag).to eql 'glass_ceramics'
      end
    end
  end
end
