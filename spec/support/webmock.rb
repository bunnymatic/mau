require 'webmock/rspec'

ALLOWED_REGEX = %r{^https://chromedriver.storage.googleapis.com/.*|^https://googlechromelabs.github.io/chrome-for-testing/*}
WebMock.disable_net_connect!(
  allow: ALLOWED_REGEX, allow_localhost: true,
)
