require 'rails_helper'

describe AdminArtistUpdateService do
  let(:service) { described_class }

  describe '.bulk_update_os' do
    let(:artists) { create_list(:artist, 3, :active, :with_studio) }
    let(:os_status_by_id) do
      artists.each_with_object({}).with_index do |(artist, memo), idx|
        memo[artist.id.to_s] = idx.even? ? '1' : '0'
      end
    end

    subject(:run) { service.bulk_update_os(os_status_by_id) }

    context 'when there are artists to change' do
      before do
        create(:open_studios_event, :future)
        run
      end

      it 'returns success with a message' do
        success, flash = run
        expect(success).to eql true
        expect(flash[:notice]).to match 'Updated setting for 2 artists'
      end

      it 'updates requested artists' do
        updated = artists.map(&:reload)
        expect(updated[0]).to be_doing_open_studios
        expect(updated[1]).not_to be_doing_open_studios
        expect(updated[2]).to be_doing_open_studios
      end
    end

    context 'when there is no current open studios' do
      before do
        run
      end
      it 'returns failure with a message' do
        success, flash = run
        expect(success).to eql false
        expect(flash[:alert]).to match 'must have an Open Studios'
      end
    end

    context 'when there are no updates to be made' do
      let(:os_status_by_id) { {} }

      before do
        create(:open_studios_event, :future)
        run
      end

      it 'returns failure with a message' do
        success, flash = run
        expect(success).to eql false
        expect(flash[:notice]).to match 'Nothing to do'
      end
    end
  end

  describe '.update' do
    let(:artist) { create(:artist) }

    before do
      artist
      allow(BryantStreetStudiosWebhook).to receive(:artist_updated)
    end

    it 'updates the artist' do
      service.update(artist, firstname: 'whatever man')
      expect(artist.reload.firstname).to eq 'whatever man'
    end

    it 'calls the webhook' do
      service.update(artist, lastname: 'whosit')
      expect(BryantStreetStudiosWebhook).to have_received(:artist_updated).with(artist.id)
    end

    context 'when there is a problem' do
      it 'returns false' do
        email = artist.email
        result = service.update(artist, email: 'not a valid email')
        expect(artist.reload.email).to eq email
        expect(result).to eq false
      end

      it 'does not call the webhook' do
        service.update(artist, email: 'not a valid email')
        expect(BryantStreetStudiosWebhook).not_to have_received(:artist_updated)
      end
    end
  end
end
