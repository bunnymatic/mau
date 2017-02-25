# frozen_string_literal: true
require 'rails_helper'

describe MediaController do
  let(:media) { FactoryGirl.create_list(:medium, 4) }
  let(:artists) { FactoryGirl.create_list(:artist, 2, :active) }
  let(:art_pieces) do
    Array.new(10) { FactoryGirl.create(:art_piece, medium_id: media.sample.id, artist: artists.sample) }
  end

  before do
    art_pieces
  end

  describe "#index" do
    context "when there is media" do
      it "redirect to show" do
        get :index, params: { format: :html }
        expect(response).to be_redirect
      end
    end
    context 'with no frequency' do
      before do
        allow(Medium).to receive(:frequency).and_return([])
      end
      it "redirect to show first" do
        get :index, params: { format: :html }
        expect(response).to redirect_to Medium.first
      end
    end
  end

  describe "#show" do
    let(:medium) { Artist.active.map(&:art_pieces).flatten.map(&:medium).first }
    context 'for valid medium' do
      let(:paginator) { assigns(:paginator) }
      context 'with pretty url' do
        before do
          get :show, params: { id: medium.slug }
        end
        it { expect(response).to be_success }
      end
      context 'by artist' do
        before do
          get :show, params: { id: medium.id, m: 'a' }
        end
        it "page is in artists mode" do
          expect(assigns(:media_presenter)).to be_by_artists
        end
        it "assigns pieces" do
          expect(paginator.items.size).to be >= 1
        end
      end
      context 'by art piece' do
        before do
          get :show, params: { id: medium }
        end
        it "page is in pieces mode" do
          expect(assigns(:media_presenter)).to be_by_pieces
        end
        it "assigns pieces" do
          expect(paginator.items.size).to be >= 1
        end
        it "assigns all media" do
          expect(assigns(:media).size).to be >= 1
        end
        it "assigns frequency" do
          expect(assigns(:frequency).size).to be >= 1
        end
        it "assigns frequency" do
          freq = assigns(:frequency)
          expect(freq).to be_present
        end
        it "pieces are in order of art_piece updated_date" do
          expect(paginator.items.map(&:updated_at)).to be_monotonically_decreasing
        end
      end
    end
  end
end
