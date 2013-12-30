module ResponseMatchers

  RSpec::Matchers.define :be_4xx do
    match do |actual|
      (actual.status.to_i >= 400) && (actual.status.to_i < 500)
    end

    failure_message_for_should do |actual|
      "expected response to be 4xx error"
    end
    
    failure_message_for_should_not do |actual|
      "expected response not to be 4xx error"
    end
    
    description do
      'have 4xx error code'
    end
  end

end

RSpec.configure do |config|
  config.include ResponseMatchers, :type => :controller
end

