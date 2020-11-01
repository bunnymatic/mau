# frozen_string_literal: true

require 'rails_helper'

describe ArtPieceTagsController do
  describe '#index' do
    describe 'format=html' do
      before do
        allow(ArtPieceTagService).to receive(:tags_sorted_by_frequency).and_return(ArtPieceTag.none)
      end
      context 'when there are no tags' do
        before do
          get :index
        end
        it_behaves_like 'renders error page'
      end
      context 'when there are tags' do
        let(:tag) { FactoryBot.build_stubbed(:art_piece_tag) }
        before do
          allow(ArtPieceTagService).to receive(:most_popular_tag).and_return(tag)
          get :index
        end
        it 'redirects to show page with the most popular tag' do
          expect(response).to redirect_to art_piece_tag_path(tag)
        end
      end
    end
    describe 'format=json' do
      before do
        allow(ArtPieceTag).to receive(:all).and_return([FactoryBot.build_stubbed(:art_piece_tag)])
      end
      context 'default' do
        before do
          get :index, params: { format: :json }
        end
        it_behaves_like 'successful json'
        it 'returns all tags as json' do
          j = JSON.parse(response.body)['art_piece_tags']
          expect(j.size).to eq(1)
        end
      end
    end
  end

  describe '#autosuggest' do
    let(:tags) { FactoryBot.create_list(:art_piece_tag, 3) }
    before do
      get :autosuggest, params: { format: 'json', input: tags.first.name.downcase }
    end
    it_behaves_like 'successful json'
    it 'returns all tags as json' do
      j = JSON.parse(response.body)
      expect(j.all?(&:present?)).to eq true
    end

    it 'writes to the cache if theres nothing there' do
      expect(Rails.cache).to receive(:read).and_return(nil)
      expect(Rails.cache).to receive(:write)
      get :autosuggest, params: { format: :json, input: 'whateverdude' }
    end

    it 'returns tags using the input' do
      get :autosuggest, params: { format: :json, input: tags.first.name.downcase }
      j = JSON.parse(response.body)
      expect(j).to be_present
    end

    it 'uses the cache there is data' do
      tag = ArtPieceTag.last
      expect(Rails.cache).to receive(:read).with(Conf.autosuggest['tags']['cache_key'])
                                           .and_return([{ 'name' => tag.name, 'id' => tag.id }])
      expect(Rails.cache).not_to receive(:write)
      get :autosuggest, params: { format: :json, input: 'tag' }
      j = JSON.parse(response.body)
      expect(j.first).to eql({ 'id' => tag.id, 'name' => tag.name })
    end
  end

  describe '#show' do
    let(:artists) { FactoryBot.create_list(:artist, 3, :with_tagged_art) }
    let(:artist) { artists.first }
    let(:tags) { artist.art_pieces.map(&:tags).flatten }
    let(:tag) { tags.first }
    before do
      tags
    end
    context 'for different tags' do
      before do
        get :show, params: { id: tag.id }
      end
      it { expect(response).to be_successful }
    end

    context 'for an unknown tag' do
      before do
        expect(ArtPieceTagService).to receive(:most_popular_tag).and_return(tag)
        get :show, params: { id: 'abc5' }
      end
      it 'redirects to the most popular tag' do
        expect(response).to redirect_to art_piece_tag_path(tag)
      end
    end
  end
end
