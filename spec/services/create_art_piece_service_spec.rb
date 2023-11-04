require 'rails_helper'

describe CreateArtPieceService do
  let(:artist) { create :artist, :active }
  let(:existing_tag) { create :art_piece_tag, name: 'existing tag' }
  let(:params) { {} }
  let(:watcher_list) { create(:watcher_email_list, :with_member) }

  subject(:service) { described_class.new(artist, params) }

  before do
    create(:open_studios_event)
    allow(WatcherMailer).to receive(:notify_new_art_piece).and_call_original
  end

  context 'when the watcher list has members' do
    before do
      watcher_list
    end
    context 'with good data' do
      let(:params) do
        attributes_for(:art_piece).merge(photo: fixture_file_upload('art.png'))
      end

      it 'creates an art piece' do
        expect { service.call }.to change(ArtPiece, :count).by(1)
      end

      it 'returns the art piece' do
        ap = service.call
        expect(ap.valid?).to eq true
      end

      it 'sends an email to the watchers' do
        service.call
        expect(WatcherMailer).to have_received(:notify_new_art_piece)
      end
    end

    context 'with tags' do
      let(:tag_params) { ['mytag', 'YourTag', 'MyTag', existing_tag.name] }
      let(:params) do
        attributes_for(:art_piece).merge(tag_ids: tag_params)
      end

      it 'creates new tags as needed' do
        existing_tag
        expect do
          service.call
          ap = ArtPiece.last
          expect(ap.tags.map(&:name)).to match_array ['mytag', 'yourtag', existing_tag.name]
        end.to change(ArtPieceTag, :count).by(2)
      end
    end

    context 'with invalid data' do
      let(:tag_params) { ['supertag', existing_tag.name] }
      let(:params) do
        attrs = attributes_for(:art_piece).merge(tag_ids: tag_params)
        attrs.delete :title
        attrs.delete :photo_file_name
        attrs
      end

      it 'returns the art piece with errors' do
        ap = service.call
        expect(ap).to be_present
        expect(ap.errors).to have_at_least(1).error
      end

      it 'does not preserve tags' do
        ap = service.call
        expect(ap.tags).to be_empty
      end

      it 'does not send an email to the watchers' do
        service.call
        expect(WatcherMailer).not_to have_received(:notify_new_art_piece)
      end
    end
  end

  context 'when the WatchersMailerList has no member' do
    it 'does not send an email to the watchers because their are none' do
      service.call
      expect(WatcherMailer).not_to have_received(:notify_new_art_piece)
    end
  end
end
