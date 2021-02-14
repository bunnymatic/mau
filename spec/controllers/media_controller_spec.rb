require 'rails_helper'

describe MediaController do
  let(:media) { FactoryBot.create_list(:medium, 4) }
  let(:artists) { FactoryBot.create_list(:artist, 2, :active) }
  let(:art_pieces) do
    Array.new(10) { FactoryBot.create(:art_piece, medium_id: media.sample.id, artist: artists.sample) }
  end

  before do
    art_pieces
  end

  describe '#index' do
    context 'when there is media' do
      it 'redirect to show' do
        get :index, params: { format: :html }
        expect(response).to be_redirect
      end
    end
    context 'with no frequency' do
      before do
        allow(MediaService).to receive(:media_sorted_by_frequency).and_return(Medium.none)
      end
      it 'redirect to show first' do
        get :index, params: { format: :html }
        expect(response).to be_not_found
      end
    end
  end

  describe '#show' do
    let(:medium) { Artist.active.map(&:art_pieces).flatten.map(&:medium).first }
    context 'for valid medium' do
      let(:paginator) { assigns(:paginator) }
      before do
        get :show, params: { id: medium }
      end
      it 'assigns pieces' do
        expect(paginator.items.size).to be >= 1
      end
      it 'pieces are in order of art_piece updated_date' do
        expect(paginator.items.map(&:updated_at)).to be_monotonically_decreasing
      end
      context 'with pretty url' do
        before do
          get :show, params: { id: medium.slug }
        end
        it { expect(response).to be_successful }
      end
    end
  end
end
