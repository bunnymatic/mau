# frozen_string_literal: true

require 'rails_helper'

describe SearchController, elasticsearch: true do
  let!(:studios) { FactoryBot.create_list :studio, 4 }
  let!(:artists) do
    FactoryBot.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios_search.first) +
      FactoryBot.create_list(:artist, 2, :active, :with_art, firstname: 'name1', studio: studios_search.last)
  end
  let(:media_search) { artists.map { |a| a.art_pieces.map(&:medium) }.flatten.compact[0..1] }
  let(:studios_search) { studios[0..1] }

  before do
    stub_search_service!
  end

  describe '#index' do
    context 'finding by studio' do
      before do
        get :index, params: { q: studios.first.name.split.first }
      end
      it 'returns success' do
        expect(response).to be_successful
      end
    end
  end
end
