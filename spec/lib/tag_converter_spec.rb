# frozen_string_literal: true
require 'rails_helper'

describe TagConverter do
  let(:existing_tags) { FactoryBot.create_list :art_piece_tag, 2 }

  let(:tag_string) { (%w(gobbledy goopers) + [existing_tags.first.name]).join(',') }
  subject(:converter) { TagConverter.new(tag_string) }
  let(:converted) { converter.convert }

  it 'returns tags' do
    expect(converted.map(&:class).uniq).to eql [ArtPieceTag]
  end

  it 'creates new tags as necessary' do
    existing_tags
    expect do
      converted
    end.to change(ArtPieceTag, :count).by(2)
  end

  it 'returns new tag objects with the right names' do
    expect(converted.first.name).to eql 'gobbledy'
    expect(converted.last.name).to eql existing_tags.first.name
  end
end
