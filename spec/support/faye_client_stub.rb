# frozen_string_literal: true
RSpec.configure do |config|
  config.before do
    stub_request(:post, 'http://localhost:3030/maumessages')
      .with(body: '[{"channel":"/meta/handshake","version":"1.0",'\
           '"supportedConnectionTypes":["long-polling"],"id":"1"}]',
           headers: { 'Content-Length' => '100', 'Content-Type' => 'application/json',
             'Cookie' => '', 'Host' => 'localhost' })
      .to_return(status: 200, body: '', headers: {})
  end
end
