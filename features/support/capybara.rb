require 'selenium/webdriver'

class CapybaraChromeConfig
  def self.chrome_capabilities(headless: false)
    Selenium::WebDriver::Chrome::Options.new.tap do |options|
      options.add_argument('--disable-popup-blocking')
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument('--window-size=1900,1200')
      if headless
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-gpu')
      end
    end
  end
end

Capybara.register_driver :chrome do |app|
  options = CapybaraChromeConfig.chrome_capabilities(headless: false)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara::Screenshot.register_driver :chrome do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.register_driver :headless_chrome do |app|
  options = CapybaraChromeConfig.chrome_capabilities(headless: true)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara::Screenshot.register_driver :chrome do |driver, path|
  driver.browser.save_screenshot(path)
end

Capybara.javascript_driver = ENV.fetch('CI', nil).presence || ENV.fetch('HEADLESS', nil).presence ? :headless_chrome : :chrome

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
rescue NoMethodError
  nil
end

World CapybaraSelect2
World CapybaraSelect2::Helpers # if need specific helpers
