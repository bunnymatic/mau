# frozen_string_literal: true

require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, debug: false, js_errors: false)
end
# Capybara.register_driver :chrome do |app|
#     Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

Capybara.javascript_driver = :poltergeist
# Capybara.javascript_driver = :webkit

# Capybara::Webkit.configure do |config|
#     config.block_unknown_urls
# end

# webkit only
Before('@javascript') do |_scenario, _block|
  if page.driver.respond_to? :header
    page.driver.header 'Authorization', ENV.fetch('API_CONSUMER_KEY', 'Testing Testing 1 2')
  else
    page.driver.add_header 'Authorization', ENV.fetch('API_CONSUMER_KEY', 'Testing Testing 1 2')
  end
end

module JavascriptDriverChecker
  def running_js?
    %i[selenium webkit chrome poltergeist].include?(Capybara.current_driver)
  end
end

World JavascriptDriverChecker

After do |_scenario|
  Capybara.reset_sessions!
end
