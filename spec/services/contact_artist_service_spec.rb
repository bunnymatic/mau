require 'rails_helper'

describe ContactArtistService do
  describe '.contact_about_art' do
    let(:art_piece) { create(:art_piece) }
    subject(:contact) do
      ContactArtistService.contact_about_art(contact_info)
    end

    before do
      allow(ArtistMailer).to receive(:contact_about_art).and_call_original
    end

    context "when everything's good" do
      let(:contact_info) do
        ContactArtistAboutArtFormData.new({ name: 'jon', email: 'jon@example.com', message: 'Awesome!', art_piece_id: art_piece.id })
      end

      it 'mails the artist' do
        contact
        expect(ActionMailer::Base.deliveries.length).to eq 1
        expect(ArtistMailer).to have_received(:contact_about_art).at_least(1).with(art_piece.artist, art_piece, contact_info.to_h)
      end
    end

    context 'when the contact info is invalid' do
      let(:contact_info) do
        ContactArtistAboutArtFormData.new({ name: 'jon' })
      end
      it 'does nothing' do
        contact
        expect(ArtistMailer).not_to have_received(:contact_about_art)
      end
    end

    context 'with an invalid art piece' do
      let(:contact_info) do
        ContactArtistAboutArtFormData.new({ name: 'jon', email: 'jon@example.com', art_piece_id: 'madeitup' })
      end
      it 'raises' do
        expect do
          contact
          expect(ArtistMailer).not_to have_received(:contact_about_art)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
