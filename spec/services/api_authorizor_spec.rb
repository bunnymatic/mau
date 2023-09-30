require 'rails_helper'

describe ApiAuthorizor do
  describe '.authorize' do
    before do
      allow(FeatureFlags).to receive(:skip_api_authorization?).and_return(false)
    end
    it 'allows internal requests through' do
      request = instance_double(ActionDispatch::Request,
                                headers: {},
                                host: 'test.host',
                                env: { 'HTTP_REFERER' => 'http://test.host' })
      expect(ApiAuthorizor.authorize(request)).to be_truthy
    end

    it 'allows external requests with the right Authorization header' do
      expect(Rails.application.config.api_consumer_key).to be_present, 'You need config.api_consumer_key to be set in test env'

      request = instance_double(ActionDispatch::Request,
                                headers: {
                                  'HTTP_AUTHORIZATION' => Rails.application.config.api_consumer_key,
                                },
                                host: 'other.host',
                                env: { 'HTTP_REFERER' => 'http://somewhere.else.com' })
      expect(ApiAuthorizor.authorize(request)).to be_truthy
    end

    it 'allows external requests with the cutom mau-api-authorization key even if Authorization header is also set' do
      expect(Rails.application.config.api_consumer_key).to be_present, 'You need config.api_consumer_key to be set in test env'

      request = instance_double(ActionDispatch::Request,
                                headers: {
                                  'HTTP_AUTHORIZATION' => 'Basic basic-auth-thing',
                                  'mau-api-authorization' => Rails.application.config.api_consumer_key,
                                },
                                host: 'other.host',
                                env: { 'HTTP_REFERER' => 'http://somewhere.else.com' })
      expect(ApiAuthorizor.authorize(request)).to be_truthy
    end

    context 'when the feature flag skip_api_authorization is on' do
      before do
        allow(FeatureFlags).to receive(:skip_api_authorization?).and_return(true)
      end

      it 'allows the request' do
        request = instance_double(ActionDispatch::Request,
                                  headers: {},
                                  host: 'other.host',
                                  env: { 'HTTP_REFERER' => 'http://somewhere.else.com' })
        expect(ApiAuthorizor.authorize(request)).to be_truthy
      end
    end
  end
end
