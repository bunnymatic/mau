# frozen_string_literal: true

require 'rails_helper'

describe CreateArtPieceService do
  let(:artist) { create :artist, :active }
  let(:existing_tag) { create :art_piece_tag, name: 'existing tag' }
  let(:params) { {} }
  let!(:watcher_list) { create(:watcher_email_list, :with_member) }

  subject(:service) { described_class.new(artist, params) }

  before do
    allow(OpenStudiosEventService).to receive(:current).and_return(build(:open_studios_event))
    allow(WatcherMailer).to receive(:notify_new_art_piece).and_call_original
  end

  context 'with good data' do
    let(:params) do
      attributes_for(:art_piece)
    end

    it 'creates an art piece' do
      expect { service.create_art_piece }.to change(ArtPiece, :count).by(1)
    end

    it 'returns the art piece' do
      ap = service.create_art_piece
      expect(ap.valid?).to eq true
    end

    it 'sends an email to the watchers' do
      service.create_art_piece
      expect(WatcherMailer).to have_received(:notify_new_art_piece)
    end

    context 'when there is no WatchersMailerList' do
      before do
        allow(WatcherMailerList).to receive(:first).and_return nil
      end
      it 'does not send an email to the watchers because their are none' do
        service.create_art_piece
        expect(WatcherMailer).not_to have_received(:notify_new_art_piece)
      end
    end
  end

  context 'with tags' do
    let(:tag_params) { ['mytag', 'YourTag', 'MyTag', existing_tag.name].join(', ') }
    let(:params) do
      attributes_for(:art_piece).merge(tags: tag_params)
    end

    it 'creates new tags as needed' do
      existing_tag
      expect do
        service.create_art_piece
        ap = ArtPiece.last
        expect(ap.tags.map(&:name)).to match_array ['mytag', 'yourtag', existing_tag.name]
      end.to change(ArtPieceTag, :count).by(2)
    end
  end

  context 'with invalid data' do
    let(:tag_params) { ['supertag', existing_tag.name].join(', ') }
    let(:params) do
      attrs = attributes_for(:art_piece).merge(tags: tag_params)
      attrs.delete :title
      attrs.delete :photo_file_name
      attrs
    end

    it 'returns the art piece with errors' do
      ap = service.create_art_piece
      expect(ap).to be_present
      expect(ap.errors).to have_at_least(1).error
    end

    it 'does not preserve tags' do
      ap = service.create_art_piece
      expect(ap.tags).to be_empty
    end

    it 'does not send an email to the watchers' do
      service.create_art_piece
      expect(WatcherMailer).not_to have_received(:notify_new_art_piece)
    end
  end
end
