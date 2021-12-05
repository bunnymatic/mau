# #require 'rack/handler/unicorn'
# Capybara.register_server(:unicorn) do |app, port, _host|
# Rack::Handler::Unicorn.run(app, Port: port)
# end
# Capybara.server = :unicorn

Capybara.register_driver :chrome do |app|
  args = %w[disable-gpu no-sandbox --enable-features=NetworkService,NetworkServiceInProcess --window-size=1700,1200]
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': { args: args },
  )
  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 capabilities: capabilities
end

Capybara.register_driver :headless_chrome do |app|
  args = %w[headless disable-gpu no-sandbox --enable-features=NetworkService,NetworkServiceInProcess --window-size=1700,1200]
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    'goog:chromeOptions': { args: args },
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome
Capybara.javascript_driver = :chrome if ENV['USE_CHROME']

Before('@javascript') do |_scenario, _block|
  if page.driver.respond_to? :header
    page.driver.header 'Authorization', ENV.fetch('API_CONSUMER_KEY', 'Testing Testing 1 2')
  elsif page.driver.respond_to? :add_header
    page.driver.add_header 'Authorization', ENV.fetch('API_CONSUMER_KEY', 'Testing Testing 1 2')
  end

  Capybara.reset!
end

module JavascriptDriverChecker
  def running_js?
    %i[selenium webkit chrome headless_chrome].include?(Capybara.current_driver)
  end
end

World JavascriptDriverChecker

Around('@javascript') do |_scenario, block|
  Capybara.reset_sessions!
  block.call
end

World CapybaraSelect2
World CapybaraSelect2::Helpers # if need specific helpers
