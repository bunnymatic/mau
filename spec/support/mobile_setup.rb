module MockMobile
  def pretend_to_be_mobile
    request.stub(:user_agent => IPHONE_USER_AGENT, :mobile_device => 'iphone')
    controller.stub(:is_mobile_device? => true, :mobile_device => 'iphone')
  end
end

RSpec.configure do |config|
  config.include MockMobile, :type => :controller
end
