require 'rails_helper'

describe ApiAuthorizor do
  describe '.authorize' do
    it "allows internal requests through" do
      request = instance_double(ActionDispatch::Request,
                                headers: {},
                                env: { "HTTP_REFERER" => 'http://test.host' }
                               )
      expect(ApiAuthorizor.authorize(request)).to be_truthy
    end

    it "refuses external requests without the proper auth key" do
      request = instance_double(ActionDispatch::Request,
                                headers: {
                                  'HTTP_AUTHORIZATION' => 'Testing Testing 1 2'
                                },
                                env: { "HTTP_REFERER" => 'http://somewhere.else.com' }
                               )
      expect(ApiAuthorizor.authorize(request)).to be_truthy
    end

    it "allows external requests with the proper auth key" do
      request = instance_double(ActionDispatch::Request,
                                headers: {},
                                env: { "HTTP_REFERER" => 'http://somewhere.else.com' }
                               )
      expect(ApiAuthorizor.authorize(request)).to be_falsy
    end
  end
end
