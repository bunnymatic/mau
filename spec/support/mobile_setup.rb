unless defined? IPHONE_USER_AGENT
  IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; XXXXX like Mac OS X; en)'\
                      ' AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A477c'\
                      ' Safari/419.3'.freeze
end

module MockMobile
  def pretend_to_be_mobile
    request.stub(user_agent: IPHONE_USER_AGENT, mobile_device: 'iphone')
  end
end

RSpec.configure do |config|
  config.include MockMobile, type: :controller
end
