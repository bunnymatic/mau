require 'rails_helper'
describe Api::V2::ContactsController do
  describe '#create' do
    let(:params) { {} }

    def execute_request(params)
      post :create, params: params
    end

    context 'with valid params' do
      let(:art_piece) { create(:art_piece) }
      let(:artist) { art_piece.artist }
      let(:params) { { name: 'joe', email: 'joe@example.com', message: 'Super', art_piece_id: art_piece.id } }
      it 'contacts the artist' do
        expect(ArtistMailer).to receive(:contact_about_art).exactly(:once).and_return(double('ArtistMailer::ContactAboutArt', deliver_later: true))
        resp = execute_request(params)
        expect(resp).to be_ok
      end
    end

    context 'with invalid params' do
      let(:art_piece) { create(:art_piece) }
      let(:artist) { art_piece.artist }
      let(:params) { { name: 'joe', art_piece_id: art_piece.id } }
      it 'contacts the artist' do
        allow(ArtistMailer).to receive(:contact_about_art)
        resp = execute_request(params)
        expect(resp).to be_bad_request
        json = JSON.parse(resp.body)
        expect(json['errors']['email']).to have_at_least(1).error
        expect(json['errors']['phone']).to have_at_least(1).error
        expect(ArtistMailer).to_not have_received(:contact_about_art)
      end
    end
  end
end
