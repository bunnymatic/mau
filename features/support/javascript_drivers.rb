# frozen_string_literal: true

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app,
                                 browser: :chrome,
                                 args: ['--window-size=1200,1200'])
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu] }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome

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
    %i[selenium webkit chrome headless_chrome poltergeist].include?(Capybara.current_driver)
  end
end

World JavascriptDriverChecker

Around('@javascript') do |_scenario, block|
  Capybara.reset_sessions!
  block.call
end
