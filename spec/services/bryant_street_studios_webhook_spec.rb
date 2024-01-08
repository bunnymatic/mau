require 'rails_helper'

describe BryantStreetStudiosWebhook do
  describe '.artist_updated' do
    it 'posts to BSS with the right headers' do
      webhook_call = stub_request(:post,
                                  %r{#{Conf.bryant_street_studios_webhook_url}/artist/5/update})
                     .with(headers: { 'bss-api-authorization' => Conf.bryant_street_studios_api_key })
      result = described_class.artist_updated(5)
      expect(webhook_call).to have_been_requested
      expect(result).to eq true
    end

    context 'if the webhook url is not in the config' do
      before do
        mock_app_config(:bryant_street_studios_webhook_url, nil)
        mock_app_config(:bryant_street_studios_api_key, 'blah')
        allow(Faraday).to receive(:new)
      end
      it 'does not post' do
        expect(described_class.artist_updated(5)).to eq false
        expect(Faraday).to_not have_received(:new)
      end
    end

    context 'if there is no api key' do
      before do
        mock_app_config(:bryant_street_studios_webhook_url, 'http://bss.whatever.com/webhook')
        mock_app_config(:bryant_street_studios_api_key, nil)
        allow(Faraday).to receive(:new)
      end
      it 'does not post' do
        expect(described_class.artist_updated(5)).to eq false
        expect(Faraday).to_not have_received(:new)
      end
    end

    context 'if there is a non 200 status code' do
      it 'returns false' do
        webhook_call = stub_request(:post,
                                    %r{#{Conf.bryant_street_studios_webhook_url}/artist/5/update}).and_return(status: 500)
        result = described_class.artist_updated(5)
        expect(webhook_call).to have_been_requested
        expect(result).to eq false
      end
    end

    context 'if there is an error raised' do
      it 'returns false' do
        allow(Faraday).to receive(:new).and_raise(StandardError, 'rats')
        expect(described_class.artist_updated(5)).to eq false
      end
    end
  end
end
